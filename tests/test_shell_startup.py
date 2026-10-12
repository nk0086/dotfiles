"""Exercise the custom zsh startup with fixture-only HOME and executables."""

from pathlib import Path
import os
import shlex
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ZSH = shutil.which("zsh")
SOURCE = (ROOT / "home-manager/programs/zsh.nix").read_text()
COMMON_INIT = SOURCE.split("    initContent = ''\n", 1)[1].split("\n    '';", 1)[0]

DARWIN_SOURCE = (ROOT / "home-manager/platforms/darwin.nix").read_text()
DARWIN_INIT = DARWIN_SOURCE.split("    initContent = lib.mkBefore ''\n", 1)[1].split("\n    '';", 1)[0]


@unittest.skipUnless(ZSH, "zsh is required")
class ShellStartupTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles test ")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        self.command("zoxide", "printf ':\\n'")
        self.env = {
            "HOME": str(self.home),
            "PATH": str(self.bin),
            "SSH_AUTH_SOCK": "existing-agent",
            "GITHUB_PERSONAL_ACCESS_TOKEN": "inherited-github",
            "OPENAI_API_KEY": "inherited-openai",
        }

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def startup(self, darwin=False):
        init = (DARWIN_INIT + "\n" if darwin else "") + COMMON_INIT
        result = subprocess.run(
            [ZSH, "-f", "-c", init + '''
print -r -- "$SSH_AUTH_SOCK"
print -r -- "$GITHUB_PERSONAL_ACCESS_TOKEN"
print -r -- "$OPENAI_API_KEY"
print -r -- "${SAFE_CHAIN_TEST:-absent}"
print -r -- "${GPG_TTY:-absent}"
'''],
            env=self.env,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=10,
            check=True,
        )
        self.assertEqual(result.stderr, "")
        return result.stdout.splitlines()

    def test_missing_optional_files_and_gpg_preserve_environment(self):
        self.assertEqual(self.startup(), [
            "existing-agent", "inherited-github", "inherited-openai", "absent", "absent"
        ])

    def test_linux_preserves_forwarded_agent_even_when_gpg_is_installed(self):
        self.command("gpgconf", "echo 'Linux must not take over the SSH agent' >&2; exit 1")
        self.assertEqual(self.startup()[0], "existing-agent")

    def test_darwin_without_gpg_preserves_existing_socket(self):
        self.assertEqual(self.startup(darwin=True)[0], "existing-agent")

    def test_startup_ignores_token_files_but_loads_safe_chain(self):
        (self.home / ".github_token").write_text("fixture-github\n")
        (self.home / ".openai_api_key").write_text("fixture-openai\n")
        script = self.home / ".safe-chain/scripts/init-posix.sh"
        script.parent.mkdir(parents=True)
        script.write_text("export SAFE_CHAIN_TEST=loaded\n")
        # Startup must not read either token file, even when they are present.
        self.command("cat", "exit 99")
        self.assertEqual(self.startup()[1:4], ["inherited-github", "inherited-openai", "loaded"])

    def test_startup_does_not_populate_unset_tokens(self):
        (self.home / ".github_token").write_text("fixture-github\n")
        (self.home / ".openai_api_key").write_text("fixture-openai\n")
        self.env.pop("GITHUB_PERSONAL_ACCESS_TOKEN")
        self.env.pop("OPENAI_API_KEY")
        self.assertEqual(self.startup()[1:3], ["", ""])

    def test_startup_does_not_open_token_fifos(self):
        # A read of either FIFO would block until the subprocess timeout.
        os.mkfifo(self.home / ".github_token")
        os.mkfifo(self.home / ".openai_api_key")
        self.assertEqual(self.startup()[1:3], ["inherited-github", "inherited-openai"])

    def test_gpg_available_uses_agent_socket_without_a_terminal(self):
        self.command("gpgconf", '''case "$1" in
  --launch) exit 0 ;;
  --list-dirs) printf 'fixture-agent\\n' ;;
esac''')
        self.command("tty", "echo 'tty must not run without a terminal' >&2; exit 1")
        output = self.startup(darwin=True)
        self.assertEqual(output[0], "fixture-agent")
        self.assertEqual(output[4], "absent")

    def test_failed_agent_launch_preserves_existing_socket(self):
        self.command("gpgconf", "exit 1")
        self.assertEqual(self.startup(darwin=True)[0], "existing-agent")

    def test_failed_socket_lookup_preserves_existing_socket(self):
        self.command("gpgconf", '''case "$1" in
  --launch) exit 0 ;;
  --list-dirs) printf 'unusable-agent\\n'; exit 1 ;;
esac''')
        self.assertEqual(self.startup(darwin=True)[0], "existing-agent")

    def test_empty_socket_lookup_preserves_existing_socket(self):
        self.command("gpgconf", "exit 0")
        self.assertEqual(self.startup(darwin=True)[0], "existing-agent")


@unittest.skipUnless(ZSH, "zsh is required")
class ScopedTokenTest(unittest.TestCase):
    HELPERS = (
        ("with-openai-key", ".openai_api_key", "OPENAI_API_KEY"),
        ("with-github-token", ".github_token", "GITHUB_PERSONAL_ACCESS_TOKEN"),
        ("gh-with-token", ".github_token", "GH_TOKEN"),
    )
    TOKENS = ("GH_TOKEN", "GITHUB_PERSONAL_ACCESS_TOKEN", "OPENAI_API_KEY")

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles token test ")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        self.env = {"HOME": str(self.home), "PATH": str(self.bin)}
        self.command("zoxide", "printf ':\\n'")
        self.probe = '''printf '%s\\n' "${GH_TOKEN-absent}" \
  "${GITHUB_PERSONAL_ACCESS_TOKEN-absent}" "${OPENAI_API_KEY-absent}"
printf 'arg:%s\\n' "$@"'''
        self.command("probe with spaces", self.probe)
        self.command("gh", self.probe)

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def shell(self, script, options=()):
        return subprocess.run(
            [ZSH, "-f", *options, "-c", COMMON_INIT + "\n" + script],
            env=self.env,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def invocation(self, helper, *args):
        command = [] if helper == "gh-with-token" else ["probe with spaces"]
        return shlex.join([helper, *command, *args])

    def test_only_selected_child_receives_token_and_arguments_are_unchanged(self):
        (self.home / ".github_token").write_text("fixture-github\n")
        (self.home / ".openai_api_key").write_text("fixture-openai\n")
        args = ("argument with spaces", "", "*", "--flag")
        for helper, filename, variable in self.HELPERS:
            with self.subTest(helper=helper):
                result = self.shell(self.invocation(helper, *args) + '\n"probe with spaces"')
                self.assertEqual(result.returncode, 0, result.stderr)
                expected_token = "fixture-openai" if filename == ".openai_api_key" else "fixture-github"
                expected = [expected_token if key == variable else "absent" for key in self.TOKENS]
                self.assertEqual(result.stdout.splitlines(), [
                    *expected, *("arg:" + arg for arg in args),
                    "absent", "absent", "absent", "arg:",
                ])
                self.assertEqual(result.stderr, "")

    def test_inherited_tokens_and_parent_shell_are_unchanged(self):
        for variable in self.TOKENS:
            self.env[variable] = "inherited-" + variable
        for helper, filename, variable in self.HELPERS:
            with self.subTest(helper=helper):
                (self.home / filename).write_text("fixture-replacement")
                result = self.shell(self.invocation(helper) + '\n"probe with spaces"')
                self.assertEqual(result.returncode, 0, result.stderr)
                inherited = [self.env[key] for key in self.TOKENS]
                child = ["fixture-replacement" if key == variable else self.env[key] for key in self.TOKENS]
                self.assertEqual(result.stdout.splitlines(), [*child, "arg:", *inherited, "arg:"])

    def test_missing_empty_whitespace_and_multiline_tokens_fail_closed(self):
        for helper, filename, _ in self.HELPERS:
            for contents in (None, "", "\n", " \t\n", "first\nsecond\n"):
                with self.subTest(helper=helper, contents=contents):
                    path = self.home / filename
                    path.unlink(missing_ok=True)
                    if contents is not None:
                        path.write_text(contents)
                    result = self.shell(self.invocation(helper))
                    self.assertEqual(result.returncode, 1)
                    self.assertEqual(result.stdout, "")
                    self.assertIn("Token file", result.stderr)

    @unittest.skipIf(os.geteuid() == 0, "root can read files without read permission")
    def test_unreadable_tokens_fail_closed(self):
        for helper, filename, _ in self.HELPERS:
            with self.subTest(helper=helper):
                path = self.home / filename
                path.write_text("fixture-unreadable")
                path.chmod(0)
                try:
                    result = self.shell(self.invocation(helper))
                    self.assertEqual(result.returncode, 1)
                    self.assertEqual(result.stdout, "")
                    self.assertIn("unreadable", result.stderr)
                finally:
                    path.chmod(0o600)

    def test_nonregular_token_files_fail_without_blocking(self):
        for helper, filename, _ in self.HELPERS:
            with self.subTest(helper=helper):
                path = self.home / filename
                path.unlink(missing_ok=True)
                os.mkfifo(path)
                result = self.shell(self.invocation(helper))
                self.assertEqual(result.returncode, 1)
                self.assertEqual(result.stdout, "")

    def test_token_is_data_never_shell_code(self):
        for helper, filename, variable in self.HELPERS:
            with self.subTest(helper=helper):
                (self.home / filename).write_text("$(>SHOULD_NOT_EXIST);`false`\\token")
                result = self.shell('cd "$HOME"\n' + self.invocation(helper))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.splitlines()[self.TOKENS.index(variable)],
                                 "$(>SHOULD_NOT_EXIST);`false`\\token")
                self.assertFalse((self.home / "SHOULD_NOT_EXIST").exists())

    def test_exit_status_is_preserved(self):
        self.command("probe with spaces", "exit 37")
        self.command("gh", "exit 37")
        for helper, filename, _ in self.HELPERS:
            with self.subTest(helper=helper):
                (self.home / filename).write_text("fixture-token")
                self.assertEqual(self.shell(self.invocation(helper)).returncode, 37)

    def test_missing_command_is_rejected(self):
        for helper in ("with-openai-key", "with-github-token"):
            with self.subTest(helper=helper):
                result = self.shell(helper)
                self.assertEqual(result.returncode, 2)
                self.assertEqual(result.stdout, "")
                self.assertIn("command is required", result.stderr)

    def test_helper_disables_xtrace_without_changing_parent_options(self):
        self.command("probe with spaces", "exit 0")
        self.command("gh", "exit 0")
        for helper, filename, _ in self.HELPERS:
            with self.subTest(helper=helper):
                (self.home / filename).write_text("fixture-never-in-trace")
                result = self.shell(self.invocation(helper) + '\n[[ -o xtrace ]]', options=("-x",))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn("fixture-never-in-trace", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
