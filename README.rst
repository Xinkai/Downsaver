What is Downsaver?
==================

The name Downsaver is "download" and "save" combined. Downsaver is a browser add-on (currently only support Mozilla Firefox; support for other browsers might be added in the future). It saves whatever media a browser loads while it is being loaded. In addition, since you will not need to sniff the resource's URL before it is saved, a second HTTP request can be avoided which saves your bandwidth and your time.

NOTE: Downsaver is still under alpha development stage. Users without programming skills are not encouraged to use it.

Disclaimer
----------

Downsaver comes with NO warranty. Downsaver developer(s) are not responsible for any defect in the software.

Downsaver users are fully responsible for all resultant consequences, including but not limited to

    * disk space being used up
    * getting sued by keeping copyrighted work
    * information being leaked out by keeping classified and/or confidential materials
    * killing yourself during making a bomb
    * getting caught for making a bomb

How to Build
============

1. Downsaver is written in `coffee-script`_. Run "cake mozilla" first to generate compiled JS files.

.. _`coffee-script`: http://coffeescript.org/

2. Downsaver for Firefox takes advantage of Mozilla Add-on SDK. Information about Mozilla Add-on SDK can be found `here`_.

.. _`here`: https://addons.mozilla.org/en-US/developers/docs/sdk/latest/


License Information
===================
Downsaver is released under BSD license.

Creator: Xinkai Chen