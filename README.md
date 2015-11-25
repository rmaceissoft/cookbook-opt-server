# otp-server-cookbook

this cookbook install Open Trip Planner and do basic setup

## Supported Platforms

Ubuntu

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['otp-server']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### otp-server::default

Include `otp-server` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[otp-server::default]"
  ]
}
```

## License and Authors

Author:: Reiner Marquez (<rmaceissoft@gmail.com>)
