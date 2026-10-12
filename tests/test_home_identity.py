"""Evaluate only the identity fields with Nix and synthetic HOME/USER values.

No flake inputs, user configuration, home files, builds, or activation are used.
"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
NIX = shutil.which("nix")


class HomeIdentityTest(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(NIX, "Nix is required to run these tests")
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles identity test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Evaluate the checked-in module as an expression, without resolving its
        # lazy imports/packages or requiring a network, daemon, or Nix store.
        module = (ROOT / "home-manager/home.nix").read_text()
        self.expression = (
            "let settings = (" + module + ") { inputs = {}; pkgs = {}; }; "
            "in { inherit (settings.home) username homeDirectory; }"
        )
        self.env = {
            "PATH": os.environ.get("PATH", ""),
            "USER": "fixture-user",
            "HOME": str(self.root / "fixture home"),
            "XDG_CONFIG_HOME": str(self.root / "config"),
            "XDG_CACHE_HOME": str(self.root / "cache"),
            "NIX_CONF_DIR": str(self.root / "nix-config"),
            "NIX_USER_CONF_FILES": "/dev/null",
        }

    def evaluate(self, *, pure=False, **values):
        env = self.env.copy()
        for name, value in values.items():
            if value is None:
                env.pop(name, None)
            else:
                env[name] = value
        return subprocess.run(
            [
                NIX, "--extra-experimental-features", "nix-command", "eval",
                "--store", "dummy://", "--offline", "--json",
                "--pure-eval" if pure else "--impure",
                "--expr", self.expression,
            ],
            cwd=ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )

    def test_identity_comes_from_environment_without_platform_prefixes(self):
        for user, home in (
            ("alice", "/Users/alice"),
            ("bob", "/home/bob"),
            ("fixture-user", "/srv/custom homes/fixture-user"),
            ("different-name", "/Volumes/Home Disk/a home"),
        ):
            with self.subTest(user=user, home=home):
                result = self.evaluate(USER=user, HOME=home)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    json.loads(result.stdout), {"username": user, "homeDirectory": home}
                )

    def test_missing_or_empty_identity_fails_with_a_clear_message(self):
        for name in ("USER", "HOME"):
            for value in (None, ""):
                with self.subTest(name=name, value=value):
                    result = self.evaluate(**{name: value})
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(f"dotfiles: {name} is empty or unavailable", result.stderr)
                    self.assertIn("--impure", result.stderr)

    def test_relative_home_fails(self):
        for home in ("home/alice", "~/alice", ".", "$HOME"):
            with self.subTest(home=home):
                result = self.evaluate(HOME=home)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("dotfiles: HOME must be an absolute path", result.stderr)

    def test_pure_evaluation_explains_the_required_flag(self):
        result = self.evaluate(pure=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("is empty or unavailable", result.stderr)
        self.assertIn("--impure", result.stderr)

    def test_platform_modules_do_not_override_identity(self):
        for name in ("darwin.nix", "linux.nix"):
            with self.subTest(platform=name):
                source = (ROOT / "home-manager/platforms" / name).read_text()
                self.assertNotIn("homeDirectory", source)
                self.assertNotIn("username", source)


if __name__ == "__main__":
    unittest.main()
