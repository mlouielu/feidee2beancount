require 'feidee_utils'

filename = ARGV[0]
kbf = FeideeUtils::Kbf.open_file(filename)
db = kbf.db

all_accounts = db.ledger::Account.all
all_transactions = db.ledger::Transaction.all
all_category = db.ledger::Category.all

# Output all of the expenditure category
cate_meta = {}
File.open('expenditure_category.beancount', 'w') do |fo|
  all_category.each do |c|
    next unless (c.poid != -1) && (c.parent_poid != -1) && (c.type == :expenditure)

    parent = db.ledger::Category.find_by_id(c.parent_poid).to_s.split(' ')[0]
    name = c.name.to_s.split(' ')[0]
    meta = format('Expenses:A%s:B%s', parent, name)
    fo.puts format('2010-01-01 open %s', meta)
  end
end

# Output transaction, balance, and transfer
# [date, type, memo, from, to, amount]
File.open('export.csv', 'w') do |fo|
  fo.puts 'date,type,memo,from,to,amount'
  all_transactions.each do |tx|
    if tx.is_transfer?
      if tx.type == :transfer_buyer
        fo.puts format('%s,transfer,"%s","%s","%s",%.0f', tx.trade_at, tx.memo.to_s,
                       tx.buyer_account.to_s.split(' ')[0], tx.seller_account.to_s.split(' ')[0], tx.amount.to_f)
      end
    elsif tx.is_initial_balance?
      fo.puts format('%s,balance,"%s",opening,"%s",%.0f', tx.trade_at, '', tx.revised_account.to_s.split(' ')[0],
                     tx.revised_amount.to_f)
    elsif tx.type == :income
      fo.puts format('%s,income,"%s","%s","%s",%.0f', tx.trade_at, tx.memo.to_s.gsub("\n", '\\n'),
                     tx.category.to_s.split(' ')[0], tx.revised_account.to_s.split(' ')[0], tx.revised_amount.to_f)
    else
      to_category = if tx.category.nil?
                      'Equity:Blackhole'
                    else
                      cate_meta[tx.category.poid]
                    end
      fo.puts format('%s,expense,"%s","%s","%s",%.0f', tx.trade_at, tx.memo.to_s.gsub("\n", '\\n'),
                     tx.revised_account.to_s.split(' ')[0], to_category, tx.revised_amount.to_f)
    end
  end
end
