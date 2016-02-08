#/bin/bash
if [ ! $1 = '' ] && [ -f $1  ] ; then
  expr $(date +%s) - $(date +%s -r $1)
fi

