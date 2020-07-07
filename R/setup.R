# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Author:   Andreas Halgreen Eiset, eiset@ph.au.dk
# Title:    Setup file for covid19 in vulnerable pop in Aarhus
# Licence:  GNU GPLv3
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

#"reset" R
graphics.off() #unload graphics

###Function to unload all loaded packages
if(length(lapply(
  names(sessionInfo()$loadedOnly),
  library,
  character.only = TRUE) == NULL) != 0) {

  invisible(lapply(
    names(sessionInfo()$loadedOnly),
    library,
    character.only = TRUE)
    )

  invisible(lapply(
    paste0('package:', names(sessionInfo()$otherPkgs)),
    detach,
    character.only = TRUE, unload = TRUE, force = TRUE)
  )
}


#load nessesary packages
tmps <- new.env()
tmps$pckg <- c("Hmisc", "rms", "tidyverse", "lubridate")
lapply(tmps$pckg, library, character.only = TRUE)
print(sapply(tmps$pckg, packageVersion))


# Setup description -------------------------------------------------------
#
# Add functions or other code that are used to setup your files so that all
# options are in one location, and referenced via a function or `source()` call.
#
