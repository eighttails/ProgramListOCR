#
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

#=============================================================================
# Language specific info
#=============================================================================

# Array of all valid language codes.
VALID_LANGUAGE_CODES="n6x hex"

# Codes for which we have webtext but no fonts:
UNUSABLE_LANGUAGE_CODES=""

N6X_FONTS=( \
    "MisakiGothic" \
    "MisakiMincho" \
    "VL Gothic" \
    "TakaoGothic" \
    "TakaoMincho" \
    "PixelMplus10" \
    "PixelMplus12" \
    "P6mk2mode1page1font" \
    "P6mk2mode5page1font" \
    "P6 Printer Routine" \
    "PiO Printer A" \
    "MSX-WIDTH40J" \
    )
    #"DotMatrix" \

HEX_FONTS=( \
    "MisakiGothic" \
    "MisakiMincho" \
    "VL Gothic" \
    "TakaoGothic" \
    "TakaoMincho" \
    "PixelMplus10" \
    "PixelMplus12" \
    "P6mk2mode1page1font" \
    "P6mk2mode5page1font" \
    "P6 Printer Routine" \
    "PiO Printer A" \
    "MSX-WIDTH40J" \
    )



# Set language-specific values for several global variables, including
#   ${TEXT_CORPUS}
#      holds the text corpus file for the language, used in phase F
#   ${FONTS[@]}
#      holds a sequence of applicable fonts for the language, used in
#      phase F & I. only set if not already set, i.e. from command line
#   ${TRAINING_DATA_ARGUMENTS}
#      non-default arguments to the training_data program used in phase T
#   ${FILTER_ARGUMENTS} -
#      character-code-specific filtering to distinguish between scripts
#      (eg. CJK) used by filter_borbidden_characters in phase F
#   ${WORDLIST2DAWG_ARGUMENTS}
#      specify fixed length dawg generation for non-space-delimited lang
# TODO(dsl): We can refactor these into functions that assign FONTS,
# TEXT_CORPUS, etc. separately.
set_lang_specific_parameters() {
  local lang=$1
  # The default text location is now given directly from the language code.
  TEXT_CORPUS="${FLAGS_webtext_prefix}/${lang}.corpus.txt"
  FILTER_ARGUMENTS=""
  WORDLIST2DAWG_ARGUMENTS=""
  # These dawg factors represent the fraction of the corpus not covered by the
  # dawg, and seem like reasonable defaults, but the optimal value is likely
  # to be highly corpus-dependent, as well as somewhat language-dependent.
  # Number dawg factor is the fraction of all numeric strings that are not
  # covered, which is why it is higher relative to the others.
  PUNC_DAWG_FACTOR=
  NUMBER_DAWG_FACTOR=0.125
  WORD_DAWG_FACTOR=0.05
  BIGRAM_DAWG_FACTOR=0.015
  TRAINING_DATA_ARGUMENTS=""
  FRAGMENTS_DISABLED="y"
  RUN_SHAPE_CLUSTERING=0
  AMBIGS_FILTER_DENOMINATOR="100000"
  LEADING="0"
  MEAN_COUNT="40"  # Default for latin script.
  # Language to mix with the language for maximum accuracy. Defaults to eng.
  # If no language is good, set to the base language.
  MIX_LANG="jpn"

  case ${lang} in
    hex ) MEAN_COUNT="15"
          WORD_DAWG_FACTOR=0.015
          GENERATE_WORD_BIGRAMS=0
          TRAINING_DATA_ARGUMENTS+=" --infrequent_ratio=10000"
          TRAINING_DATA_ARGUMENTS+=" --no_space_in_output --desired_bigrams="
          FILTER_ARGUMENTS="--charset_filter=hex --segmenter_lang=hex"
          test -z "$FONTS" && FONTS=( "${HEX_FONTS[@]}" ) ;;

    n6x ) MEAN_COUNT="15"
          WORD_DAWG_FACTOR=0.015
          GENERATE_WORD_BIGRAMS=0
          TRAINING_DATA_ARGUMENTS+=" --infrequent_ratio=10000"
          TRAINING_DATA_ARGUMENTS+=" --no_space_in_output --desired_bigrams="
          FILTER_ARGUMENTS="--charset_filter=n6x --segmenter_lang=n6x"
          test -z "$FONTS" && FONTS=( "${N6X_FONTS[@]}" ) ;;

    *) err_exit "Error: ${lang} is not a valid language code"
  esac
  if [[ ${FLAGS_mean_count} -gt 0 ]]; then
    TRAINING_DATA_ARGUMENTS+=" --mean_count=${FLAGS_mean_count}"
  elif [[ ! -z ${MEAN_COUNT} ]]; then
    TRAINING_DATA_ARGUMENTS+=" --mean_count=${MEAN_COUNT}"
  fi
  # Default to Latin fonts if none have been set
  test -z "$FONTS" && FONTS=( "${LATIN_FONTS[@]}" )

  # Default to 0 exposure if it hasn't been set
  test -z "$EXPOSURES" && EXPOSURES=0
  # Set right-to-left and normalization mode.
  case "${LANG_CODE}" in
    ara | div| fas | pus | snd | syr | uig | urd | kur_ara | heb | yid )
      LANG_IS_RTL="1"
      NORM_MODE="2" ;;
    asm | ben | bih | hin | mar | nep | guj | kan | mal | tam | tel | pan | \
    dzo | sin | san | bod | ori | khm | mya | tha | lao )
      LANG_IS_RTL="0"
      NORM_MODE="2" ;;
    * )
      LANG_IS_RTL="0"
      NORM_MODE="1" ;;
  esac
}

#=============================================================================
# END of Language specific info
#=============================================================================
