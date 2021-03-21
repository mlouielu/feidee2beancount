import csv

from dateutil.parser import parse

from beancount.core.number import D
from beancount.ingest import importer
from beancount.core import account
from beancount.core import amount
from beancount.core import flags
from beancount.core import data
from beancount.core.position import Cost

import abbr


class FeideeImporter(importer.ImporterProtocol):
    def identify(self, f):
        return True

    def extract(self, f):
        entries = []
        with open(f.name, newline="") as f:
            for index, row in enumerate(csv.DictReader(f, delimiter=",")):
                tx_date = parse(row["date"]).date()
                tx_desc = row["memo"].strip()
                tx_amt = row["amount"].strip()
                tx_payee = row["from"].strip()

                meta = data.new_metadata(f.name, index)
                tx = data.Transaction(
                    meta=meta,
                    date=tx_date,
                    flag=flags.FLAG_OKAY,
                    payee=tx_payee,
                    narration=tx_desc,
                    tags=set(),
                    links=set(),
                    postings=[],
                )

                if row["type"] == "expense":
                    to = row["to"]
                    tx_amt = -D(tx_amt)
                else:
                    to = abbr.abbr[row["to"]]

                tx.postings.append(
                    data.Posting(
                        abbr.abbr[row["from"]],
                        amount.Amount(-D(tx_amt), "TWD"),
                        None,
                        None,
                        None,
                        None,
                    )
                )
                tx.postings.append(
                    data.Posting(
                        to,
                        None,
                        None,
                        None,
                        None,
                        None,
                    )
                )

                entries.append(tx)
        return entries
