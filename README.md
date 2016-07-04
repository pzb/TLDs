# TLDs
Top Level Domain data

Each directory is one TLD.  Some TLDs use NSEC3 type DNSSEC records.  As this generates names that are salted iterated hashes of the real names, the NSEC3 names change every time the salt or iteration count changes.  These hashed names are in their own directory when present in the TLD to make it easier to differentiate between registered names and the generated names.

### Thanks
This data would not be possible without the GSA's data repository, scans.io and censys.io, https://github.com/esonderegger/dotmil-domains, and other online data sources.
