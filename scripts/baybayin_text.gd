class_name BaybayinText
extends RefCounted

## BaybayinText
## Historical pre-colonial Philippine script transliterator and dictionary.

const DICT_TERMS: Dictionary = {
	# Characters & Figures
	"haliya": "ᜑᜎᜒᜌ",                     # Ha-Li-Ya
	"haliya: mask of sorrows": "ᜑᜎᜒᜌ: ᜋᜐ᜔ᜃᜇ ᜅ᜔ ᜎᜓᜅ᜔ᜃᜓᜆ᜔",
	"bakunawa": "ᜊᜃᜓᜈᜏ",                 # Ba-Ku-Na-Wa
	"sinag-ulap": "ᜐᜒᜈᜄ᜔ ᜂᜎᜉ᜔",           # Si-Na-G U-La-P
	"mayon": "ᜋᜌᜓᜈ᜔",                     # Ma-Yo-N
	"kapre": "ᜃᜉ᜔ᜇᜒ",                     # Ka-P-Re
	"aswang": "ᜀᜐ᜔ᜏᜅ᜔",                   # A-S-Wa-Ng
	"tikbalang": "ᜆᜒᜃ᜔ᜊᜎᜅ᜔",               # Ti-K-Ba-La-Ng
	"santelmo": "ᜐᜈ᜔ᜆᜒᜎ᜔ᜋᜓ",               # Sa-N-Te-L-Mo
	
	# Stages & Realms
	"whispering canopy": "ᜊᜓᜎᜓᜅ᜔ ᜅ᜔ ᜄᜓᜊᜆ᜔",   # Bulong ng Gubat
	"ancient balete grove": "ᜊᜎᜒᜆᜒ ᜅ᜔ ᜈᜓᜈᜓ", # Balete ng Nuno
	"corrupted sentry ridge": "ᜆᜈᜓᜇ᜔ ᜊᜓᜇᜓᜎ᜔", # Tanod Burol
	"emerald terraces": "ᜊᜒᜇ᜔ᜇᜒ ᜉᜎᜌᜈ᜔",     # Berdeng Palayan
	"stilt farmstead": "ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",         # Bahay Kubo
	"the mayon crossing": "ᜆᜏᜒᜇᜈ᜔ ᜋᜌᜓᜈ᜔",   # Tawiran Mayon
	"drenched foothills": "ᜊᜐᜅ᜔ ᜊᜓᜇᜓᜎ᜔",     # Basang Burol
	"canopy torrent": "ᜊᜓᜑᜓᜐ᜔ ᜅ᜔ ᜂᜎᜈ᜔",       # Buhos ng Ulan
	"the flooded ravine": "ᜊᜈ᜔ᜎᜓᜄ᜔ ᜎᜓᜋᜓᜊᜓᜄ᜔", # Banlog Lumubog
	"moss-veiled ruins": "ᜎᜓᜋᜓᜆ᜔ ᜄᜓᜑᜓ",       # Lumot Guho
	"eye of the tempest": "ᜋᜆ ᜅ᜔ ᜊᜄ᜔ᜌᜓ",     # Mata ng Bagyo
	"bioluminescent threshold": "ᜎᜒᜏᜈᜄ᜔ ᜄᜓᜏ", # Liwanag Guweba
	"sunken lunar ruins": "ᜎᜓᜋᜓᜊᜓᜄ᜔ ᜊᜓᜏᜈ᜔",   # Lumubog Buwan
	"the abyssal gauntlet": "ᜎᜎᜓᜋ᜔ ᜇᜀᜈ᜔",     # Lalim Daan
	"bakunawa's abyss": "ᜎᜎᜓᜋ᜔ ᜅ᜔ ᜊᜃᜓᜈᜏ",     # Lalim ng Bakunawa
	
	# Concepts & UI
	"the seventh moon restored": "ᜁᜃᜉᜒᜆᜓᜅ᜔ ᜊᜓᜏᜈ᜔",
	"fall of the maiden": "ᜊᜓᜏᜈ᜔ ᜎᜓᜋᜓᜊᜓᜄ᜔",
	"ancestral lunar shrine": "ᜇᜋ᜔ᜊᜈ ᜅ᜔ ᜊᜓᜏᜈ᜔",
	"bahay kubo": "ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",
	"bahay kubo homestead": "ᜆᜑᜈᜈ᜔ ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",
	"start game": "ᜋᜄ᜔ᜉᜓᜂᜈ᜔",
	"options": "ᜉᜄ᜔ᜉᜒᜉᜒᜎᜒ"
}

# Consonant bases
const CONSONANTS = {
	"b": "ᜊ", "k": "ᜃ", "d": "ᜇ", "g": "ᜄ", "h": "ᜑ",
	"l": "ᜎ", "m": "ᜋ", "n": "ᜈ", "p": "ᜉ", "r": "ᜇ",
	"s": "ᜐ", "t": "ᜆ", "w": "ᜏ", "y": "ᜌ", "ng": "ᜅ"
}

const VOWELS = {
	"a": "ᜀ", "e": "ᜁ", "i": "ᜁ", "o": "ᜂ", "u": "ᜂ"
}

const KUDLIT_I_E = "ᜒ"
const KUDLIT_O_U = "ᜓ"
const VIRAMA = "᜔"


static func get_baybayin(text: String) -> String:
	var clean = text.strip_edges().to_lower()
	if DICT_TERMS.has(clean):
		return DICT_TERMS[clean]
	
	# Check partial dictionary match
	for key in DICT_TERMS.keys():
		if key in clean or clean in key:
			return DICT_TERMS[key]
	
	# Algorithmic transliterator
	return transliterate(clean)


static func transliterate(text: String) -> String:
	var out = ""
	var i = 0
	var len_t = text.length()
	
	while i < len_t:
		var c = text[i]
		if c == " " or c == "-" or c == ":" or c == "." or c == ",":
			out += " "
			i += 1
			continue
		
		# Check "ng" digraph
		var is_ng = (i + 1 < len_t and text.substr(i, 2) == "ng")
		var cons_key = "ng" if is_ng else c
		
		if CONSONANTS.has(cons_key):
			var step = 2 if is_ng else 1
			var base_glyph = CONSONANTS[cons_key]
			
			if i + step < len_t:
				var next_char = text[i + step]
				if next_char in ["a"]:
					out += base_glyph
					i += step + 1
				elif next_char in ["e", "i"]:
					out += base_glyph + KUDLIT_I_E
					i += step + 1
				elif next_char in ["o", "u"]:
					out += base_glyph + KUDLIT_O_U
					i += step + 1
				else:
					# Standalone consonant: attach virama
					out += base_glyph + VIRAMA
					i += step
			else:
				out += base_glyph + VIRAMA
				i += step
		elif VOWELS.has(c):
			out += VOWELS[c]
			i += 1
		else:
			# Non-transliterable punctuation or character
			out += c
			i += 1
			
	return out.strip_edges()
