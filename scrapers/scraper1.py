import requests
import scraperwiki
import lxml.html
import PyPDF2

url = "https://www.dpc.nsw.gov.au/publications/ministers-diary-disclosures/"
r = requests.get(url)
root = lxml.html.fromstring(r.content)
pdf_urls = []
pdf_as = root.cssselect(".dpc-elemental-models-elementpublicationlist .items a")

for a in pdf_as:
	pdf_urls.append("https://www.dpc.nsw.gov.au" + a.attrib['href'])

print(pdf_urls)

for pdf_url in pdf_urls:
	name = pdf_url.split("/")[-1]
	r = requests.get(pdf_url)
	with open('pdfs/{name}'.format(name=name), 'wb') as f:
		f.write(r.content)
