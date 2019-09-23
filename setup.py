from setuptools import setup, find_packages

with open('README.md') as readme:
    long_description = readme.read()

setup(
    name='bibu',
    use_scm_version=True,
    description='A Bitbucket command line client written in Python3',
    long_description='A Bitbucket command line client written in Python3',
    long_description_content_type="text/markdown",
    url='https://github.com/pylipp/bibu',
    author='Philipp Metzner',
    author_email='beth.aleph@yahoo.de',
    license='GPLv3',
    packages=find_packages(exclude=['test', 'doc']),
    entry_points = {
        # 'console_scripts': ['bibu = bibu.main:main']
        },
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Operating System :: Unix",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Topic :: Utilities",
    ],
    setup_requires=["setuptools_scm"],
    extras_require={
        "dev": [
            "twine",
            "wheel",
            "setuptools",
            "flake8",
        ],
    },
)
