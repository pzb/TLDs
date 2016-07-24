# Notes on historical TLDs

## Removed TLDs

### .root

For quite a while, ending in 2010, the root zone contained a TXT record for `vrsn-end-of-zone-marker-dummy-record.root.`. This resulted in queries for `root.` not to return NXDOMAIN.  However `root.` did not have any other records, so it did not act like a normal TLD and return records when directly queried.  For this reason it is treated in this file as TLD that was removed while many other sources do not list it as a TLD at all.

## Non-existent TLDs

A number of two letter combinations were previously assigned as ISO 3166-1 Alpha-2 codes but never used as TLDs.  Many of these predate DNS, but more recent ones are below.  Additionally at least one two letter combination that was never assigned by the ISO 3166 Maintenance Agency is rumored to be a former TLD, as discussed below.

### .cs (the 2nd)

ISO 3166-1 retired the code "CS" in 1993 when Czechoslovakia split.  The `cs.` TLD referenced this assignment.

In 2003, ISO 3166-1 reused the code "CS" for Serbia and Montenegro.  This lasted until 2006, when that country split.  As discussed in https://www.iana.org/reports/2007/rs-yu-report-11sep2007.html and https://www.iana.org/reports/2007/me-report-11sep2007.html, the `cs.` TLD was not delegated, instead Serbia and Montenegro used `yu.`.  

As it was not delegated, the file does not indicate a second removal date.

### .fx

Metropolitan France was assigned the ISO 3166-1 code of "FX" from 1993 to 1997.  It was never delegated as a TLD.

### .nt

The Saudi–Iraqi neutral zone was assign "NT" until 1993.  It was never delegated as a TLD.

### .dd

ISO 3166-1 assigned the code "DD" to the German Democratic Republic ("East Germany").  However it seems that the `dd.` TLD was never delegated in the root zone.  it was used on one or two private university networks according to some sources.

http://internet.robert-scheck.de/tld-dd/ has a fairly comprehensive write up.

### .yd

Democratic Yemen was assigned "YD" until August, 1990.  I could not find any evidence that the `yd.` TLD was ever delegated.

### .bu

Burma was assigned "BU" until December, 1989.  I could not find any evidence that the `bu.` TLD was ever delegated.

### .oz

There are some suggestions that `oz.` existed as a TLD and was eventually replaced with `au.` with the old domains moving to `oz.au.`.  However reliable data says that `au.` was delegated in 1986 as the fourth ccTLD.  The `oz.` TLD seems to never have existed in the public root.  By the time ccTLDs existed, `oz.` had moved to `oz.au.`.

http://www.ccwhois.org/ccwhois/cctld/ccTLDs-by-date.html
