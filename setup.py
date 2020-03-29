from setuptools import setup, find_packages

with open('README.md') as readme:
    long_description = readme.read()

setup(
    name='bibu',
    use_scm_version=True,
    description='A Bitbucket command line client',
    long_description='A Bitbucket command line client',
    long_description_content_type="text/markdown",
    url='https://github.com/pylipp/bibu',
    author='Philipp Metzner',
    author_email='beth.aleph@yahoo.de',
    license='GPLv3',
    data_files=[
        ("bin", ["bibu"]),
        ("lib", ["bibu.bash"]),
    ],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Operating System :: Unix",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Programming Language :: Python :: 3 :: Only",
        "Programming Language :: Unix Shell",
        "Topic :: Software Development :: Version Control",
        "Topic :: Software Development :: Version Control :: Git",
        "Topic :: Utilities",
    ],
    setup_requires=["setuptools_scm"],
    extras_require={
        "dev": [
            "twine",
            "wheel",
            "setuptools",
        ],
    },
)
