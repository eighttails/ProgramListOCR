#!/usr/bin/env python3
# (C) Copyright 2014, Google Inc.
# (C) Copyright 2018, James R Barlow
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Set some language specific variables. Works in conjunction with
# tesstrain.sh
#

# =============================================================================
# Language specific info
# =============================================================================

import logging
import os
import copy

log = logging.getLogger(__name__)

# Array of all valid language codes.
VALID_LANGUAGE_CODES = (
    "eng bas n6x hex"
)

# Codes for which we have webtext but no fonts:
UNUSABLE_LANGUAGE_CODES = ""

# ASCIIをカバーしたフォント
BASE_FONTS = [
    "PixelMplus10",
    "PixelMplus12",
    "VL Gothic",
    "TakaoGothic",
    "TakaoMincho",
    "Noto Sans Mono CJK JP Regular",
    "Noto Serif CJK JP SemiBold",
    "P6mk2mode1page1font",
    "P6mk2mode5page1font",
    "P6 Printer Routine",
    "PiO Printer A",
    "N-Font_Original",
    "MSX-FONT-Wide",
]

# ASCII特化フォント(ひらがなが出せない)
BAS_FONTS = copy.deepcopy(BASE_FONTS)
BAS_FONTS.extend([
    "DotMatrix weight=101",
    "Commodore PET",
    "lcdfont",
    "Verily Serif Mono",
])

HEX_FONTS = BAS_FONTS

# 国産BASIC特化フォント
# 美咲フォントは半角文字が小さすぎるのでASCIIのみの言語には含めない
# (ひらがな、グラフィック文字の学習に使いたい)
N6X_FONTS = copy.deepcopy(BASE_FONTS)
N6X_FONTS.extend([
    "MisakiGothic",
    "MisakiMincho",
])

VERTICAL_FONTS = []

FLAGS_webtext_prefix = os.environ.get("FLAGS_webtext_prefix", "")


# Set language-specific values for several global variables, including
#   ${TEXT_CORPUS}
#      holds the text corpus file for the language, used in phase F
#   ${FONTS[@]}
#      holds a sequence of applicable fonts for the language, used in
#      phase F & I. only set if not already set, i.e. from command line
#   ${TRAINING_DATA_ARGUMENTS}
#      non-default arguments to the training_data program used in phase T
#   ${FILTER_ARGUMENTS}[ -]
#      character-code-specific filtering to distinguish between scripts
#      (eg. CJK) used by filter_borbidden_characters in phase F
#   ${WORDLIST2DAWG_ARGUMENTS}
#      specify fixed length dawg generation for non-space-delimited lang
# TODO(dsl): We can refactor these into functions that assign FONTS,
# TEXT_CORPUS, etc. separately.
def set_lang_specific_parameters(ctx, lang):
    # The default text location is now given directly from the language code.
    TEXT_CORPUS = f"{FLAGS_webtext_prefix}/{lang}.corpus.txt"
    FILTER_ARGUMENTS = []
    WORDLIST2DAWG_ARGUMENTS = ""
    # These dawg factors represent the fraction of the corpus not covered by the
    # dawg, and seem like reasonable defaults, but the optimal value is likely
    # to be highly corpus-dependent, as well as somewhat language-dependent.
    # Number dawg factor is the fraction of all numeric strings that are not
    # covered, which is why it is higher relative to the others.
    PUNC_DAWG_FACTOR = None
    NUMBER_DAWG_FACTOR = 0.125
    WORD_DAWG_FACTOR = 0.05
    BIGRAM_DAWG_FACTOR = 0.015
    TRAINING_DATA_ARGUMENTS = []
    FRAGMENTS_DISABLED = "y"
    RUN_SHAPE_CLUSTERING = False
    AMBIGS_FILTER_DENOMINATOR = "100000"
    LEADING = 0
    MEAN_COUNT = 40  # Default for latin script.
    # Language to mix with the language for maximum accuracy. Defaults to eng.
    # If no language is good, set to the base language.
    MIX_LANG = "eng"
    FONTS = ctx.fonts
    TEXT2IMAGE_EXTRA_ARGS = ["--invert=false"]
    EXPOSURES = "0 2 4 6 -2 -4 -6 -8 -10".split()
    CHAR_SPACINGS = "0 0.7 1.4".split()

    GENERATE_WORD_BIGRAMS = None
    WORD_DAWG_SIZE = None

    LANG_IS_RTL = False
    NORM_MODE = 1

    # languages.
    if lang == "eng":
        MEAN_COUNT = "15"
        WORD_DAWG_FACTOR = 0.015
        GENERATE_WORD_BIGRAMS = 0
        TRAINING_DATA_ARGUMENTS += ["--infrequent_ratio=10000"]
        TRAINING_DATA_ARGUMENTS += ["--no_space_in_output --desired_bigrams="]
        FILTER_ARGUMENTS = ["--charset_filter=eng --segmenter_lang=eng"]
        if not FONTS:
            FONTS = HEX_FONTS
    if lang == "hex":
        MEAN_COUNT = "15"
        WORD_DAWG_FACTOR = 0.015
        GENERATE_WORD_BIGRAMS = 0
        TRAINING_DATA_ARGUMENTS += ["--infrequent_ratio=10000"]
        TRAINING_DATA_ARGUMENTS += ["--no_space_in_output --desired_bigrams="]
        FILTER_ARGUMENTS = ["--charset_filter=hex --segmenter_lang=hex"]
        if not FONTS:
            FONTS = HEX_FONTS
    elif lang == "jpn":
        MEAN_COUNT = "15"
        WORD_DAWG_FACTOR = 0.015
        GENERATE_WORD_BIGRAMS = 0
        TRAINING_DATA_ARGUMENTS += ["--infrequent_ratio=10000"]
        TRAINING_DATA_ARGUMENTS += ["--no_space_in_output --desired_bigrams="]
        FILTER_ARGUMENTS = ["--charset_filter=jpn --segmenter_lang=jpn"]
        if not FONTS:
            FONTS = N6X_FONTS
    elif lang == "n6x":
        MEAN_COUNT = "15"
        WORD_DAWG_FACTOR = 0.015
        GENERATE_WORD_BIGRAMS = 0
        TRAINING_DATA_ARGUMENTS += ["--infrequent_ratio=10000"]
        TRAINING_DATA_ARGUMENTS += ["--no_space_in_output --desired_bigrams="]
        FILTER_ARGUMENTS = ["--charset_filter=n6x --segmenter_lang=n6x"]
        if not FONTS:
            FONTS = N6X_FONTS
    elif lang == "bas":
        MEAN_COUNT = "15"
        WORD_DAWG_FACTOR = 0.015
        GENERATE_WORD_BIGRAMS = 0
        TRAINING_DATA_ARGUMENTS += ["--infrequent_ratio=10000"]
        TRAINING_DATA_ARGUMENTS += ["--no_space_in_output --desired_bigrams="]
        FILTER_ARGUMENTS = ["--charset_filter=bas --segmenter_lang=bas"]
        if not FONTS:
            FONTS = BAS_FONTS

    FLAGS_mean_count = int(os.environ.get("FLAGS_mean_count", -1))
    if FLAGS_mean_count > 0:
        TRAINING_DATA_ARGUMENTS += [f"--mean_count={FLAGS_mean_count}"]
    elif not MEAN_COUNT:
        TRAINING_DATA_ARGUMENTS += [f"--mean_count={MEAN_COUNT}"]

    # Default to Latin fonts if none have been set
    if not FONTS:
        FONTS = LATIN_FONTS

    # Default to 0 exposure if it hasn't been set
    if not EXPOSURES:
        EXPOSURES = [0]

    vars_to_transfer = {
        'ambigs_filter_denominator': AMBIGS_FILTER_DENOMINATOR,
        'bigram_dawg_factor': BIGRAM_DAWG_FACTOR,
        'exposures': EXPOSURES,
        'char_spacings': CHAR_SPACINGS,
        'filter_arguments': FILTER_ARGUMENTS,
        'fonts': FONTS,
        'fragments_disabled': FRAGMENTS_DISABLED,
        'generate_word_bigrams': GENERATE_WORD_BIGRAMS,
        'lang_is_rtl': LANG_IS_RTL,
        'leading': LEADING,
        'mean_count': MEAN_COUNT,
        'mix_lang': MIX_LANG,
        'norm_mode': NORM_MODE,
        'number_dawg_factor': NUMBER_DAWG_FACTOR,
        'punc_dawg_factor': PUNC_DAWG_FACTOR,
        'run_shape_clustering': RUN_SHAPE_CLUSTERING,
        'text2image_extra_args': TEXT2IMAGE_EXTRA_ARGS,
        'text_corpus': TEXT_CORPUS,
        'training_data_arguments': TRAINING_DATA_ARGUMENTS,
        'word_dawg_factor': WORD_DAWG_FACTOR,
        'word_dawg_size': WORD_DAWG_SIZE,
        'wordlist2dawg_arguments': WORDLIST2DAWG_ARGUMENTS,
    }

    for attr, value in vars_to_transfer.items():
        if hasattr(ctx, attr):
            if getattr(ctx, attr) != value:
                log.debug(f"{attr} = {value} (was {getattr(ctx, attr)})")
                setattr(ctx, attr, value)
            else:
                log.debug(f"{attr} = {value} (set on cmdline)")
        else:
            log.debug(f"{attr} = {value}")
            setattr(ctx, attr, value)

    return ctx

# =============================================================================
# END of Language specific info
# =============================================================================
