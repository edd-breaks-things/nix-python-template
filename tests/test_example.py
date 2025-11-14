"""Tests for the example module."""

import pytest

from example.main import add, greet


class TestGreet:
    """Test cases for the greet function."""

    def test_greet_default(self):
        """Test greet with default argument."""
        assert greet() == "Hello, World!"

    def test_greet_with_name(self):
        """Test greet with custom name."""
        assert greet("Alice") == "Hello, Alice!"

    def test_greet_with_empty_string(self):
        """Test greet with empty string."""
        assert greet("") == "Hello, !"


class TestAdd:
    """Test cases for the add function."""

    def test_add_integers(self):
        """Test adding two integers."""
        assert add(2, 3) == 5

    def test_add_floats(self):
        """Test adding two floats."""
        assert add(2.5, 3.7) == 6.2

    def test_add_mixed(self):
        """Test adding integer and float."""
        assert add(2, 3.5) == 5.5

    def test_add_negative(self):
        """Test adding negative numbers."""
        assert add(-5, 3) == -2

    def test_add_zero(self):
        """Test adding with zero."""
        assert add(0, 5) == 5
        assert add(5, 0) == 5

    @pytest.mark.parametrize(
        "a, b, expected",
        [
            (1, 1, 2),
            (0, 0, 0),
            (-1, -1, -2),
            (100, 200, 300),
        ],
    )
    def test_add_parametrized(self, a, b, expected):
        """Test add with multiple parameter sets."""
        assert add(a, b) == expected
