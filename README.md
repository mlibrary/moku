# Fauxpaas

Deploying applications has historically been complex in LIT, and the strategy for deploying
ruby applications in particular has never fully stabilized. Fauxpaas intends to address this
by treating deployment more like a service that A&E offers, with a stable, opaque API.
Developers should not need to know how their applications will be deployed, nor the intimate
details of our environment. At the same time, they need to be able to deploy, rollback,
restart, and debug their applications rapidly and on-demand.

There is one caveat: Fauxpaas does not make your first deploy much easier; it does so
for every one afterwards.

## More Info

See the documentation on
[confluence](https://tools.lib.umich.edu/confluence/display/LD/Fauxpaas+for+Developers)
