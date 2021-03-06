﻿using ARKBreedingStats.species;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;

namespace ARKBreedingStats
{
    static class CreatureColored
    {
        public static Bitmap getColoredCreature(int[] colorIds, string species, bool[] enabledColorRegions, int size = 128, int pieSize = 64, bool onlyColors = false, bool dontCache = false)
        {
            //float[][] hsl = new float[6][];
            int[][] rgb = new int[6][];
            for (int c = 0; c < 6; c++)
            {
                Color cl = CreatureColors.creatureColor(colorIds[c]);
                rgb[c] = new int[] { cl.R, cl.G, cl.B };
            }
            Bitmap bm = new Bitmap(size, size);
            using (Graphics graph = Graphics.FromImage(bm))
            {
                graph.SmoothingMode = SmoothingMode.AntiAlias;
                string imgFolder = "img/";
                // cachefilename
                string cf = imgFolder + "cache/" + species.Substring(0, Math.Min(species.Length, 5)) + "_" + (species + string.Join("", colorIds.Select(i => i.ToString()).ToArray())).GetHashCode().ToString("X8") + ".png";
                if (!onlyColors && System.IO.File.Exists(imgFolder + species + ".png") && System.IO.File.Exists(imgFolder + species + "_m.png"))
                {
                    if (!System.IO.File.Exists(cf))
                    {
                        const int defaultSizeOfTemplates = 256;
                        Bitmap bmC = new Bitmap(imgFolder + species + ".png");
                        graph.DrawImage(new Bitmap(imgFolder + species + ".png"), 0, 0, defaultSizeOfTemplates, defaultSizeOfTemplates);
                        Bitmap mask = new Bitmap(defaultSizeOfTemplates, defaultSizeOfTemplates);
                        Graphics.FromImage(mask).DrawImage(new Bitmap(imgFolder + species + "_m.png"), 0, 0, defaultSizeOfTemplates, defaultSizeOfTemplates);
                        float o = 0;
                        bool imageFine = false;
                        try
                        {
                            for (int i = 0; i < bmC.Width; i++)
                            {
                                for (int j = 0; j < bmC.Height; j++)
                                {
                                    Color bc = bmC.GetPixel(i, j);
                                    if (bc.A > 0)
                                    {
                                        int r = mask.GetPixel(i, j).R;
                                        int g = mask.GetPixel(i, j).G;
                                        int b = mask.GetPixel(i, j).B;
                                        for (int m = 0; m < 6; m++)
                                        {
                                            if (!enabledColorRegions[m] || colorIds[m] == 0)
                                                continue;
                                            switch (m)
                                            {
                                                case 0:
                                                    o = Math.Max(0, r - g - b) / 255f;
                                                    break;
                                                case 1:
                                                    o = Math.Max(0, g - r - b) / 255f;
                                                    break;
                                                case 2:
                                                    o = Math.Max(0, b - r - g) / 255f;
                                                    break;
                                                case 3:
                                                    o = Math.Min(g, b) / 255f;
                                                    break;
                                                case 4:
                                                    o = Math.Min(r, g) / 255f;
                                                    break;
                                                case 5:
                                                    o = Math.Min(r, b) / 255f;
                                                    break;
                                            }
                                            if (o == 0)
                                                continue;
                                            int rMix = bc.R + rgb[m][0] - 128;
                                            if (rMix < 0) rMix = 0;
                                            else if (rMix > 255) rMix = 255;
                                            int gMix = bc.G + rgb[m][1] - 128;
                                            if (gMix < 0) gMix = 0;
                                            else if (gMix > 255) gMix = 255;
                                            int bMix = bc.B + rgb[m][2] - 128;
                                            if (bMix < 0) bMix = 0;
                                            else if (bMix > 255) bMix = 255;
                                            Color c = Color.FromArgb(rMix, gMix, bMix);
                                            bc = Color.FromArgb(bc.A, (int)(o * c.R + (1 - o) * bc.R), (int)(o * c.G + (1 - o) * bc.G), (int)(o * c.B + (1 - o) * bc.B));
                                        }
                                        bmC.SetPixel(i, j, bc);
                                    }
                                }
                            }
                            imageFine = true;
                        }
                        catch
                        {
                            // error during drawing, maybe mask is smaller than image
                        }
                        if (imageFine)
                        {
                            if (!System.IO.Directory.Exists("img/cache"))
                                System.IO.Directory.CreateDirectory("img/cache");
                            bmC.Save(cf); // safe in cache}
                        }
                    }
                }
                if (System.IO.File.Exists(cf))
                {
                    graph.CompositingMode = CompositingMode.SourceCopy;
                    graph.CompositingQuality = CompositingQuality.HighQuality;
                    graph.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    graph.SmoothingMode = SmoothingMode.HighQuality;
                    graph.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    graph.DrawImage(new Bitmap(cf), 0, 0, size, size);
                }
                else
                {
                    // draw piechart
                    int pieAngle = enabledColorRegions.Count(c => c);
                    pieAngle = 360 / (pieAngle > 0 ? pieAngle : 1);
                    int pieNr = 0;
                    for (int c = 0; c < 6; c++)
                    {
                        if (enabledColorRegions[c])
                        {
                            if (colorIds[c] > 0)
                            {
                                using (var b = new SolidBrush(CreatureColors.creatureColor(colorIds[c])))
                                {
                                    graph.FillPie(b, (size - pieSize) / 2, (size - pieSize) / 2, pieSize, pieSize, pieNr * pieAngle + 270, pieAngle);
                                }
                            }
                            pieNr++;
                        }
                    }
                    graph.DrawEllipse(new Pen(Color.Gray), (size - pieSize) / 2, (size - pieSize) / 2, pieSize, pieSize);
                }
            }
            return bm;
        }

        public static string RegionColorInfo(string species, int[] colorIds)
        {
            string creatureRegionColors = "";
            int si = Values.V.speciesIndex(species);
            if (si >= 0)
            {
                var cs = Values.V.species[si].colors;
                creatureRegionColors = "Colors:";
                for (int r = 0; r < 6; r++)
                {
                    if (cs[r].name != null)
                    {
                        creatureRegionColors += $"\n{cs[r].name} ({r}): {CreatureColors.creatureColorName(colorIds[r])} ({colorIds[r]})";
                    }
                }
            }
            return creatureRegionColors;
        }
    }
}
