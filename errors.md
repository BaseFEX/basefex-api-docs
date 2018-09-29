# Error codes for BaseFEX

Each error JSON object consist of an error code and a message.

```js
{
    "code": "err_account_login_required",
    "message": "Login is required"
}
```

| Error Code                                   | Message                                                      |
|----------------------------------------------|--------------------------------------------------------------|
| err_account_email_required                   | Email is required                                            |
| err_account_password_required                | Password is required                                         |
| err_account_country_iso_code_required        | Country ISO code is required                                 |
| err_account_email_taken                      | Email is already taken                                       |
| err_account_send_code_failed                 | Send code failed                                             |
| err_account_verify_code_failed               | Verify code failed                                           |
| err_account_login_required                   | Login is required                                            |
| err_account_email_already_verified           | Email already verified                                       |
| err_account_tfa_already_verified             | Tfa already verified                                         |
| err_account_verify_code_required             | Verify code is required                                      |
| err_account_verify_type_required             | Verify type is required                                      |
| err_account_invalid_verify_type              | Invalid verify type                                          |
| err_account_invalid_signature                | Invalid signature                                            |
| err_account_invalid_x_api_expires            | Invalid X-API-Expires header                                 |
| err_account_api_key_expired                  | API key has expired                                          |
| err_account_old_password_required            | Old password is required                                     |
| err_account_new_password_required            | New password is required                                     |
| err_account_invalid_password                 | Invalid password                                             |
| err_account_ip_denied                        | IP address is denied                                         |
| err_account_tfa_already_enabled              | Two-Factor Authentication is already enabled                 |
| err_account_tfa_already_disabled             | Two-Factor Authentication is already disabled                |
| err_account_tfa_invalid_token                | Invalid Two-Factor Authentication token                      |
| err_account_tfa_token_required               | Two-Factor Authentication token is required                  |
| err_account_api_key_name_required            | API key name is required                                     |
| err_account_api_key_required                 | API key is required                                          |
| err_account_invalid_api_key                  | Invalid API key                                              |
| err_account_invalid_cidr                     | Invalid CIDR                                                 |
| err_account_margin_leverage_all_given        | Only one of margin or leverage is needed                     |
| err_account_margin_leverage_none_given       | At least one of margin or leverage is needed                 |
| err_account_leverage_less_than_one           | Leverage should be >= 1                                      |
| err_account_invalid_position_id              | Invalid position ID                                          |
| err_account_position_not_found               | Position is not found                                        |
| err_account_leverage_too_high                | Leverage too high                                            |
| err_account_cause_liquidation                | Position can not be updated because of immediate liquidation |
| err_account_not_enough_balance               | Position can not be updated because of insufficient fund     |
| err_account_invalid_email                    | Invalid email                                                |
| err_account_invalid_email_or_password        | Email and password do not match                              |
| err_account_invalid_tfa_token                | Invalid Two-Factor Authentication token                      |
| err_account_page_required                    | Page number is required                                      |
| err_account_invalid_size                     | Invalid size                                                 |
| err_account_invalid_symbol                   | Invalid symbol                                               |
| err_account_invalid_leaderboard_method       | Invalid leaderboard method                                   |
| err_account_token_timeout                    | Token timeout                                                |
| err_account_token_required                   | Token is required                                            |
| err_account_invalid_device                   | Invalid device                                               |
| err_account_email_verify_required            | Email verify is required                                     |
| err_account_email_code_verification_required | Email code verification required                             |
| err_account_link_timeout                     | Link timeout                                                 |
| err_account_token_invalid                    | Token invalid                                                |
| err_quotation_invalid_type_or_symbol         | Invalid candle type or symbol                                |
| err_quotation_invalid_symbol                 | invalid symbol                                               |
| err_quotation_websocket_upgrade_failed       | WebSocket upgrade failed                                     |
| err_quotation_websocket_connection_failed    | WebSocket connection failed                                  |
| err_quotation_invalid_size                   | Invalid parameter for size                                   |
| err_quotation_invalid_since                  | Invalid parameter for since                                  |
| err_exchange_order_invalid_symbol            | Invalid order symbol                                         |
| err_exchange_order_invalid_side              | Invalid order side                                           |
| err_exchange_order_invalid_size              | Invalid order size                                           |
| err_exchange_order_invalid_type              | Invalid order type                                           |
| err_exchange_order_invalid_price             | Invalid order price                                          |
| err_exchange_order_invalid_id                | invalid order ID                                             |
| err_exchange_order_not_found                 | Order is not found                                           |
| err_exchange_price_must_be_divided           | Price must be multiple of 0.5                                |
| err_exchange_size_must_be_integer            | Size must be integer                                         |
| err_exchange_cancel_order_filled             | Order can not be cancelled because it is filled              |
| err_exchange_cancel_order_canceled           | Order can not be cancelled because it is cancelled           |
| err_exchange_cancel_order_failed             | Order can not be cancelled because it has failed             |
| err_exchange_invalid_position_id             | Invalid position ID                                          |
| err_exchange_position_not_found              | Position is not found                                        |
| err_exchange_close_zero_position             | Empty position can not be closed                             |
| err_exchange_page_required                   | Page number is required                                      |
| err_exchange_invalid_size                    | Invalid size                                                 |
| err_wallet_address_required                  | Wallet address is required                                   |
| err_wallet_amount_or_fee_less_than_zero      | Amount and network fee must be > 0                           |
| err_wallet_insufficient_fund                 | Insufficient fund                                            |
| err_wallet_invalid_currency                  | Invalid currency                                             |
| err_wallet_invalid_deposit_withdraw_id       | Invalid deposit or withdraw ID                               |
