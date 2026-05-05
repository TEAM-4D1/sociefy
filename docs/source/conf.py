# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Sociefy'
copyright = '2026, Team 4D1'
author = 'Team 4D1'
release = '1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

<<<<<<< HEAD
extensions = []
=======
extensions = ['sphinx_rtd_theme']
>>>>>>> ae3b9827faa895c0f23cdbe649ff49e1e03afdfb

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

<<<<<<< HEAD
html_theme = 'alabaster'
html_static_path = ['_static']
=======
html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    'navigation_depth': 4,
    'titles_only': False,
}
html_static_path = ['_static']

# Global substitution
rst_prolog = """
.. |project_name| replace:: Sociefy
"""
>>>>>>> ae3b9827faa895c0f23cdbe649ff49e1e03afdfb
