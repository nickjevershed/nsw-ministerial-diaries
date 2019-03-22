import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import scraperwiki
import PyPDF2
import camelot
from os import listdir
import pandas as pd
import numpy as np

files = listdir("pdfs/")
words = ["23","Jan","January","Feb","February","Mar","March","Apr","April","May","Jun","June","Jul","July","Aug","August","Sep","Sept","September","Oct","October","Nov","November","Dec","December","2014","2015","2016","2017","2018"]

testfiles = ['01-Premier-Disclosure-Summary-Jan-March-2015.pdf']

for i, word in enumerate(words):
	words[i] = "-" + word
	# print(word)

# print(words)


def cleanDfName(row):
	return row['Name'].strip()	

def splitDataFrameList(df,target_column,separator):
    ''' df = dataframe to split,
    target_column = the column containing the values to split
    separator = the symbol used to perform the split
    returns: a dataframe with each entry for the target column separated, with each element moved into a new row. 
    The values in the other columns are duplicated across the newly divided rows.
    '''
    def splitListToRows(row,row_accumulator,target_column,separator):
        split_row = row[target_column].split(separator)
        for s in split_row:
            new_row = row.to_dict()
            new_row[target_column] = s
            row_accumulator.append(new_row)
    new_rows = []
    df.apply(splitListToRows,axis=1,args = (new_rows,target_column,separator))
    new_df = pd.DataFrame(new_rows)
    return new_df


def cleanFilename(fn):
	noDate = fn
	noDate = fn.replace(".pdf","")
	for word in words:
		noDate = noDate.replace(word,"")
	print(fn)
	print(noDate)
	minister = noDate
	period = fn.replace(noDate + "-","").replace(".pdf","")
	print(minister,period)
	return([minister,period])

def cleanDataframe(df, page, filename):
	print("Getting page {page}".format(page=page))
	df.columns = ['Date','Name','Reason']
	
	cleanname = cleanFilename(filename)

	df['page'] = page
	df['filename'] = filename
	df['minister'] = cleanname[0]
	df['period'] = cleanname[1]
	df['key'] = df.index.values.astype(str)

	if "ate" in df['Date'].values:
		startPos = df[df['Date']=="ate"].index.values.astype(int)[0] + 1
	elif "Date" in df['Date'].values:
		startPos = df[df['Date']=="Date"].index.values.astype(int)[0] + 1	
	else:
		startPos = 0

	endPos = len(df)
	trimmed = df[startPos:endPos]
	return trimmed


def readPDF(filename):

	pdfReader = PyPDF2.PdfFileReader("pdfs/" + filename)
	pages = pdfReader.numPages
	print(pages)

	pagesToCheck = []
	for i in range(0,pages):
		pagesToCheck.append(i + 1)

	print(pagesToCheck)	

	if len(pagesToCheck) == 1:

		pagesToCheckStr = str(pagesToCheck[0])
		
	elif len(pagesToCheck) > 1:

		pagesToCheckStr = ",".join(map(str, pagesToCheck))

			
	tables = camelot.read_pdf("pdfs/" + filename, pages=pagesToCheckStr)
	
	# camelot.plot(tables[0], kind='text')
	# plt.show()

	dfs = []

	for i, table in enumerate(tables):
		# print(table.df.head)
		clean_df = cleanDataframe(table.df, pagesToCheck[i],filename)
		split_df = splitDataFrameList(clean_df, 'Name','\n')
		split_df['Name'] = split_df.apply(cleanDfName, axis=1)
		
		dfs.append({"name":"table" + str(i),"df":split_df})

		

	megadf = pd.concat([x['df'] for x in dfs], ignore_index=True, sort=False)
	megadf = megadf.replace(r'^\s*$', np.nan, regex=True)
	
	megadf.fillna(method='ffill', inplace=True)
	data = megadf.to_dict('records')
	scraperwiki.sqlite.save(unique_keys=["key","filename","page","Name"], data=data,table_name="diaries")


for file in files:

	readPDF(file)
