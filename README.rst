Introduction to Downsaver
=========================

The name Downsaver is "download" and "save" combined. Downsaver is a browser add-on (currently only support Mozilla Firefox; support for other browsers might be added in the future). It saves whatever media a browser loads while it is being loaded. In addition, since you will not need to sniff the resource's URL before it is saved, a second HTTP request can be avoided which saves your bandwidth and your time.

NOTE: Downsaver is still under alpha development stage. For now, users without programming skills are not encouraged to use it.

Disclaimer
==========

Downsaver comes with NO warranty. Downsaver developer(s) are not responsible for any defect in the software.

Downsaver users are fully responsible for all resultant consequences, including but not limited to

    * disk space being used up
    * getting sued by keeping copyrighted work
    * information being leaked out by keeping classified and/or confidential materials
    * killing yourself during the production of a bomb
    * getting caught for making a bomb

How to Build
============

1. Have `Coffeescript`_ installed. Coffeescript depends on `node.js`_.

.. _`Coffeescript`: http://coffeescript.org/
.. _`node.js`: http://nodejs.org/

2. Have `Mozilla Add-on SDK`_ installed. Note that Mozilla Add-on SDK requires Python 2.x. Information about Mozilla Add-on SDK can be found `here`_.

.. _`Mozilla Add-on SDK`: https://ftp.mozilla.org/pub/mozilla.org/labs/jetpack/jetpack-sdk-latest.zip
.. _`here`: https://addons.mozilla.org/en-US/developers/docs/sdk/latest/

3. run '<Mozilla Add-on SDK PATH>/bin/activate'.

4. run 'cake mozilla' under project directory to generate Firefox xpi.


Roadmap
=======

Short-term goals
----------------

The following are the features being worked on:

* Graphic User Interface. It provides options so that users can choose which media they want to keep, which not. It has basic 'task management' ability, like renaming, removing, opening in player, opening origin webpage, etc.

* Multi-language support.

* Make sure the license file is complete.

* Non-geek-friendly README and stuff.

* Getting ready for the release on the AMO: check memory leaks, auto-updating...


Long-term goals
---------------

You shouldn't expect these features to come soon, or even at all.

* Custom media rules support. It provides the extensibility for users to write their own rules to determine downloadability.

* Support other browsers (Firefox Mobile, Seamonkey, Chrome, Safari, Opera, IE).


License Information
===================
Downsaver is released under the BSD-new license.

Creator: Xinkai Chen