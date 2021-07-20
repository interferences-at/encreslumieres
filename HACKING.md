# Contributing to this Project

Coding style, etc. There are also a few performance tips in here.

This file describes some development practices and coding standards for this project. Its syntax follows the rst format.

    Copyright (C)  2010-2016  Alexandre Quessy.
    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.3
    or any later version published by the Free Software Foundation;
    with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
    A copy of the license is included in the section entitled "GNU
    Free Documentation License".


## Version Number

We follow semantic versioning 2.0.
http://semver.org/

The following files contain the version number:

- src/encreslumieres/encreslumieres.pde
- NEWS.md


## The Release Process

- Create branch release-x.y.z from dev.
- Make sure the NEWS.md file is up-to-date.
- Make sure the version number in all the files with the version number is correct.
- Commit any pending changes.
- Merge into master.
- Create the tag in git.
- Create a x.y branch if needed.
- Go back to your release-x.y.z branch.
- Update the version number in NEWS.md and all files.
- Commit any pending changes.
- Merge into dev.
- Push all branches, with tags.


## The NEWS.md file

The NEWS file contains all the release notes. We list there the bugs fixed and the new features. We also explain the reason for some changes if needed.


## The README.md File

See it.


## List of pde files

Here is a short description of each file:

* src/encreslumieres/encreslumieres.pde - The main file.
* src/encreslumieres/Knot.pde - One knot in a path.
* src/encreslumieres/Path.pde - One path of spray paint. Contains many knots.
* src/encreslumieres/SprayManager.pde - One spray can. Contains many paths.


## Coding style

Let's now describe a bit the Java coding style in this project.

 * variables should be lowercase words, separated by underscores. Like "egg_spam".
 * Private class attributes should be lowercase words, separated by underscores, with a prefix underscore. Like "_egg_spam".
 * Always use the this keyword, when appropriate.
 * Class names should be camel case. Like "EggSpam".
 * File names should be like the class name.
 * The file name should be named after the single class it contains, if possible. 
 * Try to comment the methods, attributes and classes you write. Use inline comments, plus the Javadoc-style headers.
 * Try to explain what a thing does in how you name it.
 * Indent with two (2) spaces. No tabs.
 * Always use curly braces with if, for, do, and while statements. (and indent it)
 * Declare local variables as close as possible to where they are used, not in the beginning of the method.


## Libraries we use

 * oscP5
 * Syphon / Spout
 * controlP5


## Optimization

What can make this sketch use less CPU, hence be faster:

* make the step size bigger (5 pixels works well)
* make the size of the sketch smaller
* make the brush smaller (especially the eraser)
* avoid using the eraser (it's very slow, since it iterates through the pixels)
* have less brushes
* we could change the code to use P3D renderer for the PGraphics in SprayCan, 
  but then the brush will make the sketch look bad when we redraw over it.

