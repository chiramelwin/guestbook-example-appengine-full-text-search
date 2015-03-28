# How to make a Google App Engine application searchable  using self merge joins #
## Abstract ##
Many complain that Google App Engine is not able to do a full text search. However, using the presentation of Brett Slatkin at Google IO the implementation is pretty straight forward. The following article will give a practical introduction how to implement full text search on GAE. The code will be GAE/J + JDO only, but the concepts can be easily converted into Python or JPA.

## About us ##
This approach is successfully applied in our GAE project http://scisurfer.com (scientific knowledge management). We added some secret ranking sauce - but in principle it works (and scales) really well for us.

Please feel free to contact us about this post or the project any time (raphael.andre.bauer@gmail.com).

Thanks!

Nico Güttler, Dominic Jansen, Raphael Bauer
(http://corporate.scisurfer.com)


### Goal ###
  * Develop a searchable guestbook example (much like the one shipped with the SDK)
  * The full text search should be fuzzy within limits.

### Some things before we start ###
  * **Self merge joins and list properties**: You can query an entity efficiently based on so called "list properties" via self merge joins. We will not talk about that in detail, but you should watch Brett's excellent talk at Google IO 09 about the topic. It will answer everything: Google I/O 2009 - Building Scalable, Complex Apps on App Engine http://www.youtube.com/watch?v=AgaL6NGpkB8

  * **Full Text Search (FTS)**: Well. FTS is a really huge topic and can be done in a myriad of different ways. Check out wikipedia for a primer: http://en.wikipedia.org/wiki/Full_text_search

  * **The art of stemming**: One of the most basic things to enable some kind of inexact search is so called "stemming". It's the reduction of words towards their basic form. http://en.wikipedia.org/wiki/Stemming


## The project ##
The whole project is available at google code: http://code.google.com/p/guestbook-example-appengine-full-text-search

A live demo is available at http://guestbook-example-fts.appspot.com/

### The project - walk-through indexing ###
  * **guestbook.jsp**: This file is the first file that is loaded. You can enter new entries into the guestbook (GuestBookEntry.java). But you can also search all guestbook entries using the upper form.
  * **GuestBookEntry.java**: A simple JDO file with persistent fields. However, there is one special field: **fts**. It is a Set of Strings. They will be filled with the terms that allow for a full text search. If you inspect the constructor, you will see a call to
```
SearchJanitor.updateFTSStuffForGuestBookEntry(this);
```
This call is responsible for making this GuestBookEntry searchable.
  * **SearchJanitor.java - method updateFTSStuffForGuestBookEntry**: This method gets a GuestBookEntry and chops it into single words using the SearchJanitorUtils method
```
SearchJanitorUtils.getTokensForIndexingOrQuery(...)
```
  * **SearchJanitorUtils.getTokensForIndexingOrQuery(...)**: This method uses Lucene and Lucene Snowball to extract words from the given String. But it does more: The Lucene Snowball stemmer reduces the words to the basic form what enables fuzzy search. A search for Kids or Kid will return the same results. kid and Kids will also return the same results.


**Summary indexing**: Ok. So far we have an entity (GuestBookEntry.java) that will be filled with a set of Strings generated from it's content (SearchJanitor.updateFTSStuffForGuestBookEntry(...).
Cool. But the "real" search is missing.



### The project - walk-through searching ###
  * **search.jsp**: This file gets a parameter "search" and presents results for that search. It does that by consulting
```
List<GuestBookEntry> searchResults = SearchJanitor.searchGuestBookEntries(searchString, pm);
```
  * **SearchJanitor - method searchGuestBookEntries**: This method does all the "magic". It again chops the search string into single, stemmed words (using the SearchJanitorUtils) and constructs a query that searches for all these Strings in the field "fts" of entity GuestBookEntry.

```
    StringBuffer queryBuffer = new StringBuffer();

        queryBuffer.append("SELECT FROM " + GuestBookEntry.class.getName() + " WHERE ");

        Set<String> queryTokens = SearchJanitorUtils
                .getTokensForIndexingOrQuery(queryString,
                        MAXIMUM_NUMBER_OF_WORDS_TO_SEARCH);

        List<String> parametersForSearch = new ArrayList<String>(queryTokens);

        StringBuffer declareParametersBuffer = new StringBuffer();

        int parameterCounter = 0;

        while (parameterCounter < queryTokens.size()) {

            queryBuffer.append("fts == param" + parameterCounter);
            declareParametersBuffer.append("String param" + parameterCounter);

            if (parameterCounter + 1 < queryTokens.size()) {
                queryBuffer.append(" && ");
                declareParametersBuffer.append(", ");

            }

            parameterCounter++;

        }

    
        Query query = pm.newQuery(queryBuffer.toString());

        query.declareParameters(declareParametersBuffer.toString());

        List<GuestBookEntry> result = (List<GuestBookEntry>) query.executeWithArray(parametersForSearch
                .toArray());
    
```

**Summary**: We have a search.jsp that uses the same stemming as in the indexing part to translate a string into a searchable set of strings. This set of strings is then in turn queried against the datastore (in the form of self merge joins on one field). Mission accomplished.




### Limitations of the approach ###
  * 1MB limit on entities. You cannot store more than 1MB in one entity. You can of course work around this limitation by generating more than one entity. Or even a special kind of "FTSEntity".
  * Number of terms to search for limited (max around 5 => but precise enough). You cannot search for a unlimited number of query terms as you are doing a (potentially costly) self merge join. But in 99.9% of the cases the results the user will get with a limited set of search terms will be fine.
  * If you get too many results this approach will not work. You have to make sure you are searching in a subset of the data with less than ~200 results. That's up to you. If you do not have many entities you are querying this error will never show up. If you have thousands of entries you should make sure you are only getting subsets. E.g. by only retrieving the "best" (secret sauce) results. Or only results from a particular day or so.


### Outlook ###
Where to go from here:
  * Use reference entities to omit serialization costs (as outlined in Brett Slatkin's talk)
  * Add key only queries for more efficient searches http://gae-java-persistence.blogspot.com/2009/10/keys-only-queries.html
  * Add memcache support for fast queries http://code.google.com/appengine/docs/java/memcache/overview.html
  * Add some secret sauce that enables you to "rank" results
  * Precompute date and timestamps to search for them. Don't search for ranges, but search for exact dates like 2009-10 (all entries in August 2009).


## Summary ##
This post showed you how to use self merge joins to index entities of the Google App Engine and make them searchable. The approach has limitations, but it proves that the GAE can be made full text searchable.