using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing.Imaging;
using System.IO;

namespace ImageParser
{

    public partial class Form1 : Form
    {
        const int OUTPUT_HEIGHT = 100;
        const int OUTPUT_WIDTH = 100;
        private Rectangle myRect = new Rectangle(0,0,100,100);
        private Brush myBrush;
        private Graphics myGraphics; 

        const string SOURCE = "C:\\Users\\kaublezw\\Pictures\\Screenshots";
        const string TARGET = "C:\\Users\\kaublezw\\Desktop\\3-Leaf Clovers\\";
        Image im;

        private float imageScale = 1.0f;
        private int imageWidth, imageHeight;
        private int fileIndex = 0;

        private List<string> myFiles = new List<string>();

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // this.MouseWheel += Form1_MouseWheel;
      
            this.pictureBox1.MouseClick += PictureBox1_MouseClick;
            this.pictureBox1.MouseMove += PictureBox1_MouseMove;
            this.pictureBox1.MouseWheel += PictureBox1_MouseWheel;
            this.pictureBox1.Paint += PictureBox1_Paint;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;
            this.KeyDown += Form1_KeyDown;



            //pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            //            pictureBox1.Size = new Size(imageWidth, imageHeight);

            this.WindowState = FormWindowState.Maximized;

            // load directory of files

            myFiles = Directory.GetFiles(SOURCE, "*.png").ToList<string>();
            im = Image.FromFile(myFiles[fileIndex]);

            pictureBox1.Image = im;

            myGraphics = pictureBox1.CreateGraphics();
            myBrush = new SolidBrush(Color.Red);


        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
           if ((e.KeyCode == Keys.F) && (fileIndex + 1 < myFiles.Count))
            {
                fileIndex++;
                im = Image.FromFile(myFiles[fileIndex]);
                pictureBox1.Image = im;

            }
           else if ((e.KeyCode == Keys.D) && (fileIndex - 1 >= 0))
            {
                fileIndex--;
                im = Image.FromFile(myFiles[fileIndex]);
                pictureBox1.Image = im;
            }
        }

        private void PictureBox1_MouseWheel(object sender, MouseEventArgs e)
        {
            if (e.Delta > 0)
            {
                myRect.Width += 4;
                myRect.Height += 4;
            }
            else
            {
                myRect.Width -= 4;
                myRect.Height -= 4;

            }
            this.pictureBox1.Invalidate();
        }

        private void PictureBox1_Paint(object sender, PaintEventArgs e)
        {
           
            e.Graphics.DrawRectangle(new Pen(myBrush), myRect);
                   
        }

        private void PictureBox1_MouseMove(object sender, MouseEventArgs e)
        {
            myRect.X = e.X;
            myRect.Y = e.Y;
            this.pictureBox1.Invalidate();         
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var myFiles = Directory.GetFiles("C:\\Users\\kaublezw\\Desktop\\Four-Leaf Clovers\\", "*.bmp").ToList<string>();
            foreach (var file in myFiles)
            {
                var im = Image.FromFile(file);
                
                im.Save(file.Substring(0,file.Length-5)+".png",ImageFormat.Png);
            }
        }

        private void PictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            //throw new NotImplementedException();

            var bmpScreenShot = new Bitmap(myRect.Width, myRect.Height);
            var gfxScreenShot = Graphics.FromImage(bmpScreenShot);

            gfxScreenShot.CopyFromScreen(myRect.X+13, myRect.Y+36, 0, 0, new Size(myRect.Width-1, myRect.Height-1));

            bmpScreenShot.Save(TARGET + DateTime.Now.Ticks.ToString()  + ".bmp", ImageFormat.Bmp);
        }

    }
}
