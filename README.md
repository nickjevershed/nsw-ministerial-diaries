# NSW ministerial diaries
Cleaned scraper output from the NSW ministerial diary PDFs

## Known issues:
* Where multiple entities attend a meeting, I have chosen to split those into seperate entries to allow proper counting of meetings by entity. This means that where an entity name runs over two lines, the second line has been truncated and will be counted as a new entity. This should be taken into account when doing counts by entity name or minister or date

* Some cleaning of entity names has been done, but there are still many examples of name variation that clearly are referring to the same entity. This should be taken into account when presenting results of counts by entity name

## Scrapers

Scraper 1 gets all the PDFs, Scraper 2 reads the PDFs into a sqlite database 
