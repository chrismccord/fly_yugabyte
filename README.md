Speed run:

    $ fly apps create my-yuga

Update your fly.toml to replace "your-app-here" with your app name.

Next, run the `init_cluster` script, which uses `fly vol create`, `fly deploy`, and `fly scale count`
to provision and scale your cluster in multiple regions.

For example, to create a 3 region cluster in `iad`, `ord`, and `lax`:

    $ ./init_cluster --region iad,ord,lax -a my-yuga

After the cluster is up, you can configure the data placement, for example:

    ️$ fly ssh console -C "./bin/yugabyted configure data_placement --base_dir=/yb_data --fault_tolerance=region --rf=3"

    +--------------------------------------------------------------------------------------+
    |                                      yugabyted                                       |
    +--------------------------------------------------------------------------------------+
    | Status        : Configuration successful. Primary data placement is geo-redundant.   |
    | Fault Tolerance: Primary Cluster can survive at most any 1 region failure.           |
    +--------------------------------------------------------------------------------------+

Follow the steps in the [Fly private VPN network](https://fly.io/docs/networking/private-networking/#private-network-vpn)
guide to securely connect from your local computer to your yuga cluster. This will allow you to hit the YugabyteDB management
console at the .internal url, such as: `http://iad.my-yuga.internal:15433`.

*Note*: The cluster is provisioned with a default postgres username and password of
`yugabyte/yugabyte`. It also does not use TLS encryption as the 6PN private network
between fly instanes is already encrypted, and the fly app via `fly.toml` does *not expose
any publicly reachable services*. Only applications within the app's organization can
access the local fly ipv6 private network. If you intend to deploy a YugabyteDB cluster that
is exposed to the internet, see [Yugabyte's security documetnation](https://docs.yugabyte.com/preview/secure/tls-encryption/client-to-server/).

You can change the default password with:

    psql "psql://yugabyte:yugabyte@$PRIMARY_REGION.$APP.internal:15433"

    yugabyte=# ALTER ROLE yugabyte PASSWOD 'my-new-password'

## Adding new masters

Assuming you have 3 nodes in regions iad,ord,lax, you can scale to more regions
by first provisionining a volume in each new region:

    $ fly vol create yb_data --region lhr --size 1 -a ybx
    $ fly vol create yb_data --region waw --size 1 -a ybx

Then run fly scale to scale up 5 regions:

    $ fly scale count 5 --max-per-region=1 --region iad,ord,lax,lhr,waw --vm-size performance-2x