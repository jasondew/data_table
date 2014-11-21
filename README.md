DataTable
=========

```
DataTable context: self,
          data: apply_scopes(Coupon).viewable,
          columns: [
            {
              presenter: ->(coupon) { coupon.presenter.selector_html },
              order_by: :brand
            },
            {
              presenter: ->(coupon) { link_to coupon, coupon },
              order_by: :brand
            },
            :value,
            :size,
            :source,
            :category,
            :authority,
            :expires_on,
            {
              presenter: ->(coupon) { link_to("Print", coupon.url) if coupon.url.present? },
              order_by: :url
            }
          ],
          search_fields: %w(public_format url)
```
