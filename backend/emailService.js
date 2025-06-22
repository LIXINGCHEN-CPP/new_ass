const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = null;
    this.initialized = false;
  }

  async initializeTransporter() {
    try {

      const useRealEmail = process.env.GMAIL_USER && process.env.GMAIL_APP_PASSWORD;
      
      if (useRealEmail) {
        
        this.transporter = nodemailer.createTransport({
          service: 'gmail',
          auth: {
            user: process.env.GMAIL_USER,
            pass: process.env.GMAIL_APP_PASSWORD
          }
        });
        console.log('Email service initialized with Gmail SMTP');
      } else {
        // Use Ethereal Email for testing
        const testAccount = await nodemailer.createTestAccount();
        this.transporter = nodemailer.createTransport({
          host: 'smtp.ethereal.email',
          port: 587,
          secure: false,
          auth: {
            user: testAccount.user,
            pass: testAccount.pass
          }
        });
        console.log(' Email service initialized with Ethereal Email (testing)');
        console.log(`Test email credentials: ${testAccount.user} / ${testAccount.pass}`);
      }
    } catch (error) {
      console.error('Failed to initialize email service:', error);
      this.transporter = null;
    }
  }

  generateVerificationCode() {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  async ensureInitialized() {
    if (!this.initialized) {
      console.log('Initializing email service...');
      await this.initializeTransporter();
      this.initialized = true;
    }
  }

  async sendPasswordResetCode(email, code) {
    await this.ensureInitialized();
    
    if (!this.transporter) {
      throw new Error('Email service not initialized');
    }

    const mailOptions = {
      from: '"E-Grocery Store" <noreply@e-grocery.com>',
      to: email,
      subject: 'Password Reset Verification Code - E-Grocery Store',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #4CAF50; margin: 0;">E-Grocery Store</h1>
            <p style="color: #666; margin: 5px 0;">Your Online Grocery Store</p>
          </div>
          
          <div style="background-color: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin-top: 0;">Password Reset Request</h2>
            <p style="color: #666; line-height: 1.6;">
              Hello!<br><br>
              We received your password reset request. Please use the following verification code to reset your password:
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <div style="background-color: #4CAF50; color: white; font-size: 32px; font-weight: bold; padding: 15px 30px; border-radius: 8px; display: inline-block; letter-spacing: 5px;">
                ${code}
              </div>
            </div>
            
            <p style="color: #666; line-height: 1.6;">
              <strong>Important Notes:</strong><br>
              • This verification code will expire in <strong>10 minutes</strong><br>
              • Each verification code can only be used once<br>
              • If you did not request a password reset, please ignore this email
            </p>
          </div>
          
          <div style="border-top: 1px solid #eee; padding-top: 20px; text-align: center;">
            <p style="color: #999; font-size: 12px; margin: 0;">
              This email was sent automatically, please do not reply.<br>
              If you have any questions, please contact customer support.
            </p>
          </div>
        </div>
      `
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log('Password reset email sent:', info.messageId);
      
      // For test accounts, log the preview URL
      if (nodemailer.getTestMessageUrl(info)) {
        console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
      }
      
      return {
        success: true,
        messageId: info.messageId,
        previewUrl: nodemailer.getTestMessageUrl(info)
      };
    } catch (error) {
      console.error('Failed to send password reset email:', error);
      throw error;
    }
  }
}

module.exports = new EmailService(); 