"""Package-level smoke tests."""

import rag_production


def test_package_exposes_installed_version() -> None:
    """The package can be imported without starting external integrations."""
    assert rag_production.__version__ == "0.1.0"
