import pandas as pd

#Importing the Loughran and McDonald Dictionary
data=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/LoughranMcDonald_MasterDictionary_2016.csv')

#Creating the dictionary
#Replacing figures with 1s and 0s (1 if contained in section, 0 otherwise)
neg=data.Negative.unique()[data.Negative.unique()!=0]
pos=data.Positive.unique()[data.Positive.unique()!=0]
unc=data.Uncertainty.unique()[data.Uncertainty.unique()!=0]
lit=data.Litigious.unique()[data.Litigious.unique()!=0]
con=data.Constraining.unique()[data.Constraining.unique()!=0]
sup=data.Superfluous.unique()[data.Superfluous.unique()!=0]
inte=data.Interesting.unique()[data.Interesting.unique()!=0]
data['Negative']=data.Negative.replace(neg,1)
data['Positive']=data.Positive.replace(pos,1)
data['Uncertainty']=data.Uncertainty.replace(unc,1)
data['Litigious']=data.Litigious.replace(lit,1)
data['Constraining']=data.Constraining.replace(con,1)
data['Superfluous']=data.Superfluous.replace(sup,1)
data['Interesting']=data.Interesting.replace(inte,1)

#Building the dictionary dataframe
dict=pd.DataFrame(columns=['Word', 'Negative', 'Positive', 'Uncertainty', 'Litigious', 'Constraining', 'Superfluous', 'Interesting'])
dict.Word=data.Word.astype('str')
dict.Negative=data.Negative
dict.Positive=data.Positive
dict.Uncertainty=data.Uncertainty
dict.Litigious=data.Litigious
dict.Constraining=data.Constraining
dict.Superfluous=data.Superfluous
dict.Interesting=data.Interesting

#Functions to simplify and lemmatize the dictionary words to match our words
def to_lowercase(words):
    """Convert all characters to lowercase from list of tokenized words"""
    new_words = []
    for word in words:
        new_word = word.lower()
        new_words.append(new_word)
    return new_words

    """Lemmatize verbs in list of tokenized words"""
    lemmatizer = WordNetLemmatizer()
    lemmas = []
    for word in words:
        lemma = lemmatizer.lemmatize(word, pos='v')
        lemmas.append(lemma)
    return lemmas

def normalize(words):
    words = to_lowercase(words)
    lemmas = lemmatize_verbs(words)
    return words

dict.Word = normalize(dict.Word)
