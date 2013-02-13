#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "regex.h"
#include "ppport.h"
#include "const-c.inc"

MODULE = Data::Validate::DNS::NAPTR::Regexp PACKAGE = Data::Validate::DNS::NAPTR::Regexp

INCLUDE: const-xs.inc
PROTOTYPES: Enable

void
_regcomp(regex, cflags)
    char *regex
    int cflags
  PPCODE:
    int ret;
    regex_t preg;
    char regerr[256];

    EXTEND(SP, 2);

    memset(&preg, 0, sizeof(preg));

    ret = regcomp(&preg, regex, cflags);

    if (ret) {
      regerror(ret, &preg, regerr, sizeof(regerr));

      PUSHs(&PL_sv_undef);
      PUSHs(sv_2mortal(newSVpv(regerr, 0)));
    } else {
      regfree(&preg);

      PUSHs(sv_2mortal(newSViv(preg.re_nsub)));
    }
