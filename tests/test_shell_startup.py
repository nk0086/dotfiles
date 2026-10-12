"""Exercise the custom zsh startup with fixture-only HOME and executables."""

from pathlib import Path
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

    def test_present_files_and_safe_chain_with_spaces_in_home(self):
        (self.home / ".github_token").write_text("fixture-github\n")
        (self.home / ".openai_api_key").write_text("fixture-openai\n")
        script = self.home / ".safe-chain/scripts/init-posix.sh"
        script.parent.mkdir(parents=True)
        script.write_text("export SAFE_CHAIN_TEST=loaded\n")
        # The user's cat alias must not interfere with reading optional files.
        self.command("cat", "exit 99")
        self.assertEqual(self.startup()[1:4], ["fixture-github", "fixture-openai", "loaded"])

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


if __name__ == "__main__":
    unittest.main()
