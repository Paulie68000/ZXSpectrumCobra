# ZXSpectrumCobra
Full reverse engineered source code of Jonathan "Joffa" Smith's Cobra for the 48K Spectrum.

Back in the eighties I had the pleasure to work with Joff at Ocean / Special FX and later in the noughties at Warthog Games.

Cobra was an absolute Z80 masterpiece, and when Joff passed a lot of that knowledge passed with him.

As something of an archiver of old 8 bit source code I thought the source for Cobra should somehow be restored and explained for posterity.

Armed with the help of the wonderful Spectrum Analyser tool, I set about to fully document Cobra based on many long chats with Joff, and the pleasure of working with his code over the years; Joff was the master of creating highly reusable code that 
you see all through his numerous games.

After a few weeks of evenings, I present fully documented source code, named pretty much how he named his functions back in the day, as an ASM file that can be assembled by SJAsmPlus back into a
working snapshot file.

The code is heavily documented, but I'll add some more notes here on some of thinking behind the scrolling technique, the sprite plotting and the multiplexed "Plip Plop" audio player as they deserve
special attention, due to some proper oblique thinking!

Enjoy!

## **1. The Scroller**

Probably the cleverest part of Cobra is the horizontal scroll routine.  Cobra can scroll a 224 x 144 pixel window left and right, 2 pixels at a time along with the corresponding 28 x 16 attributes in around half a frame.
If Cobra didn't bother with its in game jingles and SFX it could run happily at 50 frames per second.  However it burns up a second frame to allow it to have its excellent (for a buzzer) sounds, and so the final game runs at 25fps with
the parallax scrolling ground running at 50fps.

Before we get into the how, first some terminology as a preamble to the core idea. 

Each level has a "byte per tile" map that is 256 x 8 bytes. Each byte in the map corresponds to a 16 x 16 pixel Tile graphic and so that translates to a 4096 x 128 pixel map per level (or round in Cobra's parlance)

The main currency of the scroller is a TileBlock which consists of three 16 x 16 tiles that scan be scrolled into each other.  These tile blocks are pre shifted four times at the start of the level.

Each Level has a total of 9 tile blocks.  The first tile block is used for the parallax ground scroll and fully wraps around itself.  The following 8 TileBlocks are built of three 16x16 Tiles; the first tile is the left edge
of the triple block the second is a middle block that can be repeated to make a long run of a platform and final an end block of the triple that scrolls blank data in.

Each 16 pixel high row of the screen can contain a maximum of two Tile Block triples plus a blank / parallax block giving us a maximum of 7 16 x 16 Tiles per 16 pixel row. 

### Putting it all together

So, how does all this work?  So, the entire map draw is done with a combination of unrolled PUSH instructions; each register pair represents a tile.  HL holds the blank/parallax tile, BC, DE and AF hold the three tiles of the tile block.

At the start of the frame the game scans the game map and generates the sequence of PUSH instructions need for the 14 tiles of each row, as the code is being generated the game can switch to using a second Tileblock which POPs in
three new adresses into BC, DE and AF for a seond Tileblcok.  Each of the 8 rows of the screen has code generated for the push sequences required.

The map draw consists of simply executing this generated code.  When we want to shift over two pixels all we need to do is update the offset to the next pre-shifted triple of blocks and execute the same code again.  It's worth noting that
Cobra draw directly to screen memory and uses no back buffers.  It draws the map to the screen, followed by the sprites which is timed via "the floating bus trick" to ensure that we're racing the beam and drawing everything buffer the
raster scan catches up with us.

As the player scrolls the map, the map code is generated every time the map scroll position modulo 8 == 0, as for the next four scrolls of two pixels, the scroll is simply executing the same code with the block offset changed.

There's quite a bit of nuance to the map draw as we need to double buffer the map generation code so we can execute one batch to draw the current frame whilst we prepare the code for the next frame.

<img width="1308" alt="Cobra Tiles" src="https://github.com/user-attachments/assets/e329bd91-9fda-4c8f-88aa-32d992dfee6d">


## The Sprites

