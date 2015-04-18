using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace GetPixelInfo
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.AutoSize = true;
        }

        private void btOpen_Click(object sender, EventArgs e)
        {
            int i, j;
            int R, G, B;
            OpenFileDialog file = new OpenFileDialog();
            file.InitialDirectory = "C:\\Users\\Juan Carlos\\Documents\\Boston University\\Spring 2015\\Advanced Digital Design with Verilog and FPGA EC551\\Project\\Sprites\\explosion2";
            try
            {
                if (file.ShowDialog() == DialogResult.OK)
                {
                    Bitmap image = new Bitmap(file.FileName);
                    HPx.Text = Convert.ToString(image.Width) + "x" + Convert.ToString(image.Height);
                    string pxByte_s;
                    System.IO.StreamWriter WriteFile = new System.IO.StreamWriter(file.FileName.Substring(0, file.FileName.IndexOf(".")) + ".coe");
                    WriteFile.WriteLine("MEMORY_INITIALIZATION_RADIX=2;");
                    WriteFile.WriteLine("MEMORY_INITIALIZATION_VECTOR=");
                    for (j = 0; j < image.Height; j++)
                    {
                        for (i = 0; i < image.Width; i++)
                        {
                            Color pxInfo = image.GetPixel(i, j);
                            R = pxInfo.R & 224;
                            G = (pxInfo.G & 224) >> 3;
                            B = (pxInfo.B & 192) >> 6;
                            pxByte_s = Convert.ToString(R + G + B, 2).PadLeft(8, '0');
                            if (!(i == image.Width - 1 && j == image.Height - 1))
                                WriteFile.WriteLine(pxByte_s + ",");
                            else
                                WriteFile.WriteLine(pxByte_s + ";");
                        }
                    }
                    WriteFile.Close();
                    label1.ForeColor = System.Drawing.Color.Green;
                    label1.Text = "DONE!";
                    label2.Text = "File created: " + file.FileName.Substring(0, file.FileName.IndexOf(".")) + ".coe";
                }
            }
            catch
            {
                label1.ForeColor = System.Drawing.Color.Red;
                label1.Text = "ERROR!";
            }
        }
    }
}
