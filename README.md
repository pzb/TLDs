# Top Level Domains

Every host name on the Internet ends with a top level domain.  It is the part after the last period.  For example com, net, org, us, au, and za are all top level domains.

Most top level domains fall into two categories: country code TLDs or generic TLDs.  A few are test domains that are no longer used. However a very small number don't really fall into any of the previous categories.  These are:

  * arpa
  * edu
  * gov
  * int
  * mil

Data on these domains is somewhat hard to come by.  The zone for arpa can be downloaded from https://www.internic.net/domains/arpa.zone, but the registries for gov, mil, and int do not have zone file access programs and edu has no documented zone file access program policies.

This data is the result of research into these zones.  It uses data from various sources (see the Thanks section) to help gather the info that would be available if zone files were published.  It is an approximation of what is likely in the zone files but may be incomplete.

Each directory is for one TLD and may contain both DNS and WHOIS information (where available).  For some TLDs that use NSEC3 type DNSSEC records, the names that are hashes are separated into their own directory to help isolate the churn caused by salt or iteration count updates.

### Contact

For questions or comments, please contact Peter Bowen <pzbowen@gmail.com>.

### Thanks
This data would not be possible without the GSA's data repository, UMich's scans.io and censys.io, the https://github.com/esonderegger/dotmil-domains data, and many other online data sources.
