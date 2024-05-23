Speed run:

$ fly apps create my-yuga

Update your fly.toml to replace "your-app-here" with your app name.

Next, run the `init_cluster` script, which uses `fly vol create`, `fly deploy`, and `fly scale count`
to provision and scale your cluster in multiple regions.

For example, to create a 3 region cluster in `iad`, `ord`, and `lax`:

    ./init_cluster --region iad,ord,lax -a my-yuga

After the cluster is up, you can configure the data placement, for example:

    fly ssh console -C "./bin/yugabyted configure data_placement --fault_tolerance=region --rf=3"

Follow the steps in the [Fly private VPN network](https://fly.io/docs/networking/private-networking/#private-network-vpn)
guide to securely connect from your local computer to your yuga cluster. This will allow you to hit the YugabyteDB management
console at the .internal url, such as: `http://iad.my-yuga.internal:15433`.

*Note*: The cluster is provisioned insecurely