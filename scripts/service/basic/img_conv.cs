using System;
using System.Drawing;
using System.IO;

class Program
{
    static void Main()
    {
        using (Bitmap bmp = new Bitmap("image.png"))
        {
            Icon icon = Icon.FromHandle(bmp.GetHicon());
            using (FileStream fs = new FileStream("output.ico", FileMode.Create))
            {
                icon.Save(fs);
            }
        }
    }
}
