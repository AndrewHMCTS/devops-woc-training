from maths import add_numbers
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (10, 5, 15),])

def test_add_numbers(a: int, b: int, expected: int) -> int:
    assert add_numbers(a, b) == expected