#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "regex.h"
#include "ppport.h"
#include "const-c.inc"

/* typedef struct regex_t regex_t */

MODULE = Data::Validate::NAPTR::Regexp		PACKAGE = Data::Validate::NAPTR::Regexp

INCLUDE: const-xs.inc
PROTOTYPES: Enable

regex_t * _regcomp(regex, cflags)
    char *regex
    int cflags
  CODE:
    int ret;
    regex_t *preg;
    char regerr[256];

    preg = (regex_t *) malloc(sizeof(regex_t));
    ret = regcomp(preg, regex, cflags);
    if (ret) {
      regerror(ret, preg, regerr, sizeof(regerr));
      regfree(preg);
      free(preg);
      croak("%s\n", regerr);
    }

    RETVAL = preg;
  OUTPUT:
    RETVAL

MODULE = Data::Validate::NAPTR::Regexp	PACKAGE = regex_tPtr PREFIX = regtestb_

void
regtestb_DESTROY(preg)
    regex_t *preg
  CODE:
    regfree(preg);
    free(preg);

SV * regtestb_re_nsub (preg)
    regex_t * preg
  CODE:
    ST(0) = sv_newmortal();
    sv_setnv( ST(0), preg->re_nsub );


