# Intro #
Google's App Engine does not (yet) provide full text search capabilities. However, it is quite straight forward to implement a basic full text search using self merge joins.

This example should help to illustrate how things work in principle.

How to tutorial:
http://code.google.com/p/guestbook-example-appengine-full-text-search/wiki/HowTo

Source code:
http://code.google.com/p/guestbook-example-appengine-full-text-search/source/browse/#svn/trunk/

Live demo:
http://guestbook-example-fts.appspot.com




## Third party libraries remark ##
This project uses the core of Lucene 2.9.1 (http://lucene.apache.org Apache license) together with Tartarus Snowball Libraries (http://snowball.tartarus.org/ BSD licencse). But Lucene is about FTS - right? Do you use that? No. We do not use Lucene for FTS. We simply need a good stemmer and that is why we came to use Lucene + Snowball.