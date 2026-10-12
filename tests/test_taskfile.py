"""Check local target selection and host guards with fixture commands; never run Nix."""

import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TASK = shutil.which("task")
TARGETS = {
    "mac": "myHomeConfig",
    "linux": "linuxHomeConfig",
    "linux-arm64": "linuxArmHomeConfig",
}

HOSTS = {
    "mac": ("Darwin", "arm64"),
    "linux": ("Linux", "x86_64"),
    "linux-arm64": ("Linux", "aarch64"),
}


class TaskfileTest(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(TASK, "go-task is required to run these tests")
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles task test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Test a copy so Task cannot change the checkout's files or task cache.
        for name in ("Taskfile.yml", ".env.local.example", ".gitignore"):
            shutil.copyfile(ROOT / name, self.root / name)
        self.env = os.environ.copy()
        for name in ("TARGET", "HOME_CONFIG", "TASK_DRY", "TASK_SILENT"):
            self.env.pop(name, None)
        self.env["NO_COLOR"] = "1"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        uname = self.bin / "uname"
        uname.write_text(
            '#!/bin/sh\ncase "$1" in\n'
            '  -s) printf "%s\\n" "$TEST_UNAME_SYSTEM" ;;\n'
            '  -m) printf "%s\\n" "$TEST_UNAME_MACHINE" ;;\n'
            '  *) exit 1 ;;\nesac\n'
        )
        uname.chmod(0o755)
        nix = self.bin / "nix"
        nix.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$TEST_NIX_ARGS"\n')
        nix.chmod(0o755)
        self.nix_args = self.root / "nix-args"
        self.env["TEST_NIX_ARGS"] = str(self.nix_args)
        self.env["PATH"] = str(self.bin) + os.pathsep + self.env["PATH"]

    def set_local_target(self, target):
        (self.root / ".env.local").write_text(f"TARGET='{target}'\n")

    def run_task(self, task, target=None, *extra_vars, host=None, dry=True):
        args = [TASK]
        if dry:
            args.append("--dry")
        args.append(task)
        if target is not None:
            args.append("TARGET=" + target)
        args.extend(extra_vars)
        env = self.env.copy()
        env["TEST_UNAME_SYSTEM"], env["TEST_UNAME_MACHINE"] = (
            host if host is not None else HOSTS.get(target, HOSTS["mac"])
        )
        return subprocess.run(
            args,
            cwd=self.root,
            env=env,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )

    def command(self, task, target=None, *extra_vars, host=None):
        result = self.run_task(task, target, *extra_vars, host=host)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        lines = output.strip().splitlines()
        self.assertEqual(len(lines), 1, output)
        self.assertTrue(lines[0].startswith("task: ["), output)
        return shlex.split(lines[0].split("] ", 1)[1])

    def expected_command(self, task, config):
        if task == "build":
            return [
                "nix", "build", "--impure", "--no-update-lock-file",
                f".#homeConfigurations.{config}.activationPackage",
            ]
        return [
            "nix", "run", "--no-update-lock-file", "--inputs-from", ".",
            "home-manager", "--", "switch", "--impure", "--no-update-lock-file",
            "--flake", f".#{config}",
        ]

    def test_local_file_selects_all_targets_without_cli_variables(self):
        for task in ("build", "apply", "sync"):
            for target, config in TARGETS.items():
                with self.subTest(task=task, target=target):
                    self.set_local_target(target)
                    self.assertEqual(
                        self.command(task, host=HOSTS[target]),
                        self.expected_command(task, config),
                    )

    def test_missing_local_target_does_not_fall_back_to_example_or_mac(self):
        # An example is present in every fixture, but Task must never load it.
        (self.root / ".env.local.example").write_text("TARGET=mac\n")
        for contents in (None, "# target not configured\n", "TARGET=\n"):
            if contents is not None:
                (self.root / ".env.local").write_text(contents)
            for task in ("build", "apply", "sync"):
                with self.subTest(task=task, contents=contents):
                    result = self.run_task(task, dry=False)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("TARGET", result.stdout + result.stderr)
                    self.assertFalse(self.nix_args.exists())

    def test_example_requires_an_explicit_target(self):
        shutil.copyfile(self.root / ".env.local.example", self.root / ".env.local")
        result = self.run_task("build", dry=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.nix_args.exists())

    def test_cli_target_can_explicitly_override_the_local_file(self):
        for target, config in TARGETS.items():
            for local_target in TARGETS:
                self.set_local_target(local_target)
                for task in ("build", "apply", "sync"):
                    with self.subTest(task=task, target=target, local=local_target):
                        self.assertEqual(
                            self.command(task, target), self.expected_command(task, config)
                        )

    def test_local_file_survives_repeated_commands_and_taskfile_refresh(self):
        contents = "# Keep my machine setting and comments.\nTARGET=linux\n"
        local = self.root / ".env.local"
        local.write_text(contents)
        for _ in range(2):
            shutil.copyfile(ROOT / "Taskfile.yml", self.root / "Taskfile.yml")
            for task in ("build", "apply", "sync"):
                result = self.run_task(task, host=HOSTS["linux"], dry=False)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(
                    self.nix_args.read_text().splitlines(),
                    self.expected_command(task, TARGETS["linux"])[1:],
                )
                self.assertEqual(local.read_text(), contents)

    def test_git_ignores_only_the_local_file_and_keeps_the_example(self):
        self.set_local_target("linux")
        for args in (["init", "--quiet"], ["add", "Taskfile.yml", ".gitignore", ".env.local.example"]):
            subprocess.run(["git", *args], cwd=self.root, check=True, capture_output=True)
        ignored = subprocess.run(
            ["git", "check-ignore", ".env.local", ".env.local.example"],
            cwd=self.root, check=True, capture_output=True, text=True,
        )
        self.assertEqual(ignored.stdout.splitlines(), [".env.local"])
        tracked = subprocess.run(
            ["git", "ls-files"], cwd=self.root, check=True, capture_output=True, text=True,
        ).stdout.splitlines()
        self.assertNotIn(".env.local", tracked)
        self.assertIn(".env.local.example", tracked)

    def test_sync_alias_honors_target(self):
        for target, config in TARGETS.items():
            with self.subTest(target=target):
                self.assertEqual(
                    self.command("sync", target), self.expected_command("apply", config)
                )

    def test_legacy_home_config_cannot_override_target(self):
        for task in ("build", "apply", "sync"):
            for target, config in TARGETS.items():
                with self.subTest(task=task, target=target):
                    self.assertEqual(
                        self.command(task, target, "HOME_CONFIG=unselectedConfig"),
                        self.expected_command(task, config),
                    )

    def test_invalid_targets_fail_before_any_command(self):
        for task in ("build", "apply", "sync"):
            for target in ("macos", "windows", "", "linux ", "mac; echo unexpected"):
                with self.subTest(task=task, target=target):
                    result = self.run_task(task, target)
                    output = result.stdout + result.stderr
                    self.assertNotEqual(result.returncode, 0, output)
                    self.assertIn("TARGET has an invalid value", output)
                    self.assertNotIn("task: [", output)

    def test_invalid_local_targets_fail_before_running_nix(self):
        for task in ("build", "apply", "sync"):
            for target in ("macos", "windows", "", "linux ", "mac; echo unexpected"):
                with self.subTest(task=task, target=target):
                    self.set_local_target(target)
                    result = self.run_task(task, dry=False)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("TARGET has an invalid value", result.stdout + result.stderr)
                    self.assertFalse(self.nix_args.exists())

    def test_apply_and_sync_reject_wrong_host_os_or_cpu(self):
        for task in ("apply", "sync"):
            for target in TARGETS:
                for host in (*HOSTS.values(), ("Darwin", "x86_64"), ("Linux", "riscv64")):
                    if host == HOSTS[target]:
                        continue
                    with self.subTest(task=task, target=target, host=host):
                        result = self.run_task(task, target, host=host)
                        output = result.stdout + result.stderr
                        self.assertNotEqual(result.returncode, 0, output)
                        self.assertIn("TARGET must match this host's OS/CPU", output)
                        self.assertNotIn("task: [", output)

    def test_build_allows_a_different_host_for_remote_builders(self):
        for target in TARGETS:
            with self.subTest(target=target):
                result = self.run_task("build", target, host=("OtherOS", "othercpu"))
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("--impure", result.stdout + result.stderr)

    def test_update_only_updates_the_lock_file(self):
        self.assertEqual(self.command("update"), ["nix", "flake", "update"])

    def test_old_host_wrappers_are_removed(self):
        for task in ("build", "apply"):
            for host in ("macos", "linux", "linux-arm64"):
                with self.subTest(task=task, host=host):
                    result = self.run_task(f"{task}:{host}")
                    self.assertNotEqual(result.returncode, 0)
                    self.assertNotIn("task: [", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
