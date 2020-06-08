;Helper constants
Ch          =      0               ;DAC channel to use
DACOff      =      0               ;Value to set the DAC to when "off" (in V)
NLoop       =      8*300           ;Maximum stimulation duration (in number of loops)

;Configuration
            SET    0.01,1,0        ;msPerStep, DACscale, DACoffset

            VAR    V1,VFreq        ;Cosine frequency
            VAR    V2,VSize        ;Cosine amplitude
            VAR    V3,VOffset      ;Cosine offset
            VAR    V5,VLoopC       ;Loop counter


;Program start
E0:     'Q  RATE   Ch,0            ;Stop any ongoing stimulation (Keyboard shortcut 'Q')
            DAC    Ch,DACOff       ;Set DAC value to "off"
            MARK   0               ;Digital mark 0

            HALT                   ;End of sequence

            ;Await stimulation sequence start

        'S  RATE   Ch,0            ;Set parameters and start cosine (Keyboard shortcut 'S')
            PHASE  Ch,180          ;Set initial cosine phase to start at minimum
            ANGLE  Ch,0            ;Set cosine phase step
            CLRC   Ch              ;Clear wait flag
            MOVI   VLoopC,NLoop    ;Set maximum number of cycles
            ;FIXME: use RATE 0 to avoid transient plus ANGLE or DELAY for no phase drift
LOOP0:      SZ     Ch,VSize        ;Set cosine amplitude
            OFFSET Ch,VOffset      ;Set cosine centre
            RATE   Ch,VFreq        ;Set rate and start cosine
            MARK   1               ;Digital mark 1
WAIT0:      WAITC  Ch,WAIT0        ;Wait for the next cycle
            DBNZ   VLoopC,LOOP0    ;Loop
            JUMP   E0              ;Stop if something goes wrong
