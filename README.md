Feidee2beancount - 隨手記導入至 beancount
=========================================

WARNING: Use with your wise, code didn't look great, but it works for me.


Requirements
------------

* Ruby
* Python 3

```
$ gem install feidee_utils
$ python -m pip install beancount --user
```

Export from Feidee
------------------

This will output two files:

* expenditure_category.beancount: Your expenditure category
  - Output with `Expenses:A<category>:B<sub-category>`
  - Default open at `2010-01-01`

* export.csv: Your transaction/balance/transfer export data
  - Transfer will NOT handle currency exchange, you will need to deal it manually
  - If category was deleted, it will output with `Equity:Blackhole` category
  - Please open `Equity:Blackhole` category manually in your beancount
  - Balance will transfer from `opening`

此動作將產生兩個檔案

* expenditure_category.beancount: 該檔案的支出分類
  - 預設輸出為 `Expenses:A<category>:B<sub-category>`
  - 舉例：食品酒水/早午晚餐 -> Expenses:A食品酒水:B早午晚餐
  - 預設 open 日期為 `2010-01-01`

* export.csv: 你的所有交易/不平衡支出/轉帳紀錄
  - 轉帳紀錄沒有辦法處理幣別轉換，你需要自己手動解決
  - 如果該支出分類被刪除了，將會使用 `Equity:Blackhole` 代替
  - 請自行 open `Equity:Blackhole`
  - 不平衡支出將使用 `opening`

```
$ ruby feidee_export.rb <YOUR_FEIDEE_DATABASE.kbf>
$ ls
expenditure_category.beancount export.csv ...
```

Import to beancount
-------------------

This will convert `export.csv` to beancount transaction & postings by beancount
Python API.

* You will need to define your account abbriviation in `abbr.py` for Equity/Assets/Income/Liabilities.

```
$ bean-extract config.py export.csv > feidee.beancount
```


Check by fava
-------------

```
$python -m pip install fava --user
$ fava feidee.beancount
```
