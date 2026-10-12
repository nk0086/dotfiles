"""Check Task's rendered commands without running Nix or applying a profile."""

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


class TaskfileTest(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(TASK, "go-task is required to run these tests")
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles task test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Test a copy so Task cannot change the checkout's files or task cache.
        shutil.copyfile(ROOT / "Taskfile.yml", self.root / "Taskfile.yml")
        self.env = os.environ.copy()
        for name in ("TARGET", "HOME_CONFIG", "TASK_DRY", "TASK_SILENT"):
            self.env.pop(name, None)
        self.env["NO_COLOR"] = "1"

    def dry_run(self, task, target=None, *extra_vars):
        args = [TASK, "--dry", task]
        if target is not None:
            args.append("TARGET=" + target)
        args.extend(extra_vars)
        return subprocess.run(
            args,
            cwd=self.root,
            env=self.env,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )

    def command(self, task, target=None, *extra_vars):
        result = self.dry_run(task, target, *extra_vars)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        lines = output.strip().splitlines()
        self.assertEqual(len(lines), 1, output)
        self.assertTrue(lines[0].startswith("task: ["), output)
        return shlex.split(lines[0].split("] ", 1)[1])

    def expected_command(self, task, config):
        if task == "build":
            return [
                "nix", "build", "--no-update-lock-file",
                f".#homeConfigurations.{config}.activationPackage",
            ]
        return [
            "nix", "run", "--no-update-lock-file", "--inputs-from", ".",
            "home-manager", "--", "switch", "--no-update-lock-file",
            "--flake", f".#{config}",
        ]

    def test_all_targets_select_the_expected_output(self):
        for task in ("build", "apply"):
            for target, config in TARGETS.items():
                with self.subTest(task=task, target=target):
                    self.assertEqual(
                        self.command(task, target), self.expected_command(task, config)
                    )

    def test_default_target_remains_mac(self):
        for task in ("build", "apply", "sync"):
            with self.subTest(task=task):
                self.assertEqual(
                    self.command(task), self.expected_command(task, TARGETS["mac"])
                )

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
                    result = self.dry_run(task, target)
                    output = result.stdout + result.stderr
                    self.assertNotEqual(result.returncode, 0, output)
                    self.assertIn("TARGET has an invalid value", output)
                    self.assertNotIn("task: [", output)

    def test_update_only_updates_the_lock_file(self):
        self.assertEqual(self.command("update"), ["nix", "flake", "update"])

    def test_old_host_wrappers_are_removed(self):
        for task in ("build", "apply"):
            for host in ("macos", "linux", "linux-arm64"):
                with self.subTest(task=task, host=host):
                    result = self.dry_run(f"{task}:{host}")
                    self.assertNotEqual(result.returncode, 0)
                    self.assertNotIn("task: [", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
