/***********************************************************************
 * Double inked list
 ***********************************************************************/
 
#ifndef _ALINK_H
#define _ALINK_H

typedef struct ALLink_s {
    struct ALLink_s      *next;
    struct ALLink_s      *prev;
} ALLink;

void    alUnlink(ALLink *element);
void    alLink(ALLink *element, ALLink *after);

#endif
