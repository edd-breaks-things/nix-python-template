"""Example module demonstrating Python package structure."""


def greet(name: str = "World") -> str:
    """
    Generate a greeting message.

    Args:
        name: The name to greet (default: "World")

    Returns:
        A greeting message string
    """
    return f"Hello, {name}!"


def add(a: int | float, b: int | float) -> int | float:
    """
    Add two numbers together.

    Args:
        a: First number
        b: Second number

    Returns:
        The sum of a and b
    """
    return a + b


def main() -> None:
    """Main entry point for the example module."""
    print(greet())
    print(f"2 + 3 = {add(2, 3)}")


if __name__ == "__main__":
    main()
