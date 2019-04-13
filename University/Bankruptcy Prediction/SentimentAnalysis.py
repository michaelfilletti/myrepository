import pandas as pd
import inflect
from nltk.corpus import stopwords
from nltk.stem import LancasterStemmer, WordNetLemmatizer

data=pd.read_csv('/Users/michaelfilletti/Desktop/news700_gaming.csv',encoding = "ISO-8859-1")

gamingdata2013=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news4_igaming_sector_2013.csv',encoding = "ISO-8859-1")
gamingdata2014=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news4._igaming_sector_2014.csv',encoding = "ISO-8859-1")
gamingdata2015=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_igaming_sector_2015.csv',encoding = "ISO-8859-1")
gamingdata2016=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_igaming_sector_2016.csv',encoding = "ISO-8859-1")
gamingdata2017=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_igaming_sector_2017.csv',encoding = "ISO-8859-1")
gamingdata2015=gamingdata2015.drop(['Article'], axis=1)
gamingdata2015.columns=['Title','Author','Article_Year','Article']
gamingdata=pd.concat([gamingdata2013,gamingdata2014,gamingdata2015,gamingdata2016,gamingdata2017],ignore_index=True)

pharmadata=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_pharma_2013_2018.csv',encoding = "ISO-8859-1")
tourismdata=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_tourism_2013_2018.csv',encoding = "ISO-8859-1")
aviationdata=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/Article Data/news_aviation_2013_2018.csv',encoding = "ISO-8859-1")

gamingdata['Sector']='Gaming'
pharmadata['Sector']='Pharmaceuticals'
tourismdata['Sector']='Tourism'
aviationdata['Sector']='Aviation'


def datacleaner(data,year1):
    global new
    data=data[data['Article_Year']==year1]
    new = data['Article'].str.split(" ", expand = True)
    new = new.drop(range(0,49),axis=1)
    return new

def remove_non_ascii(words):
    """Remove non-ASCII characters from list of tokenized words"""
    new_words = []
    for word in words:
        new_word = unicodedata.normalize('NFKD', word).encode('ascii', 'ignore').decode('utf-8', 'ignore')
        new_words.append(new_word)
    return new_words

def to_lowercase(words):
    """Convert all characters to lowercase from list of tokenized words"""
    new_words = []
    for word in words:
        new_word = word.lower()
        new_words.append(new_word)
    return new_words

def remove_punctuation(words):
    """Remove punctuation from list of tokenized words"""
    new_words = []
    for word in words:
        new_word = re.sub(r'[^\w\s]', '', word)
        if new_word != '':
            new_words.append(new_word)
    return new_words

def replace_numbers(words):
    """Replace all interger occurrences in list of tokenized words with textual representation"""
    p = inflect.engine()
    new_words = []
    for word in words:
        if word.isdigit():
            new_word = p.number_to_words(word)
            new_words.append(new_word)
        else:
            new_words.append(word)
    return new_words

def remove_stopwords(words):
    """Remove stop words from list of tokenized words"""
    new_words = []
    for word in words:
        if word not in stopwords.words('english'):
            new_words.append(word)
    return new_words

def stem_words(words):
    """Stem words in list of tokenized words"""
    stemmer = LancasterStemmer()
    stems = []
    for word in words:
        stem = stemmer.stem(word)
        stems.append(stem)
    return stems

def lemmatize_verbs(words):
    """Lemmatize verbs in list of tokenized words"""
    lemmatizer = WordNetLemmatizer()
    lemmas = []
    for word in words:
        lemma = lemmatizer.lemmatize(word, pos='v')
        lemmas.append(lemma)
    return lemmas

def normalize(words):
    words = remove_non_ascii(words)
    words = to_lowercase(words)
    words = remove_punctuation(words)
    words = replace_numbers(words)
    words = remove_stopwords(words)
    return words

def stem_and_lemmatize(words):
    stems = stem_words(words)
    lemmas = lemmatize_verbs(words)
    return stems, lemmas