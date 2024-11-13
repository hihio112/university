from PySide6.QtCore import (QCoreApplication, 
    QMetaObject, Qt, QThread, Slot, Signal)

from PySide6.QtWidgets import (QApplication, QComboBox, QFormLayout, QLabel,
    QLineEdit, QPushButton,  QTextEdit,
    QWidget, QHBoxLayout)
from PySide6.QtSerialPort import QSerialPortInfo
from serial import Serial

import matplotlib.pyplot as plt
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas


from matplotlib import pyplot as plt
import numpy as np

import pandas as pd
from pandas import Series, DataFrame



class Ui_Form(object):
    def setupUi(self, Form):
        if not Form.objectName():
            Form.setObjectName(u"Form")
        Form.resize(1100, 700)
        self.formLayout = QFormLayout(Form)
        self.formLayout.setObjectName(u"formLayout")
        self.label = QLabel(Form)
        self.label.setObjectName(u"label")
        self.label.setAlignment(Qt.AlignCenter)

        self.formLayout.setWidget(0, QFormLayout.LabelRole, self.label)

        self.comboBox = QComboBox(Form)
        self.comboBox.setObjectName(u"comboBox")

        self.formLayout.setWidget(0, QFormLayout.FieldRole, self.comboBox)

        self.label_2 = QLabel(Form)
        self.label_2.setObjectName(u"label_2")
        self.label_2.setAlignment(Qt.AlignCenter)

        self.formLayout.setWidget(1, QFormLayout.LabelRole, self.label_2)

        self.comboBox_2 = QComboBox(Form)
        self.comboBox_2.setObjectName(u"comboBox_2")

        self.formLayout.setWidget(1, QFormLayout.FieldRole, self.comboBox_2)

        self.pushButton = QPushButton(Form)
        self.pushButton.setObjectName(u"pushButton")

        self.formLayout.setWidget(2, QFormLayout.LabelRole, self.pushButton)

        self.pushButton_2 = QPushButton(Form)
        self.pushButton_2.setObjectName(u"pushButton_2")

        self.formLayout.setWidget(2, QFormLayout.FieldRole, self.pushButton_2)



        self.horizontalLayout = QHBoxLayout()


        self.lineEdit = QLineEdit(Form)
        self.lineEdit.setObjectName(u"lineEdit")
        self.horizontalLayout.addWidget(self.lineEdit)


        self.pushButton_3_1 = QPushButton('clear',self)
        
        self.pushButton_3 = QPushButton(Form)
        self.pushButton_3.setObjectName(u"pushButton_3")
        
        self.horizontalLayout.addWidget(self.pushButton_3_1)
        #self.horizontalLayout.addStretch(1)
        self.horizontalLayout.addWidget(self.pushButton_3)
        
        self.formLayout.setLayout(3, QFormLayout.FieldRole, self.horizontalLayout)

        self.textEdit = QTextEdit()
        self.textEdit.setObjectName(u"textEdit")

        self.formLayout.setWidget(4, QFormLayout.SpanningRole, self.textEdit)

      
        self.fig = plt.Figure()
        self.canvas = FigureCanvas(self.fig)
        self.formLayout.setWidget(5, QFormLayout.SpanningRole, self.canvas)
        
        #clicked
        self.original_xlim = None
        self.original_ylim = None
        self.clicked=False
        random_array = np.random.rand(1024, 100)
        self.draw_heatmap(random_array)
        self.canvas.mpl_connect('button_press_event', self.onclick)
        
        
        self.retranslateUi(Form)

        QMetaObject.connectSlotsByName(Form)
    # setupUi

    def draw_heatmap(self, data):
        self.fig.clear()
        ax = self.fig.add_subplot(111)
        ax.clear()  
        
        
        cax = ax.matshow(data, aspect='auto')
        self.fig.colorbar(cax, pad = 0.01, aspect = 40)
        self.fig.subplots_adjust(left=0.05, right=1.1, top=0.9, bottom=0.01)
        self.original_xlim = ax.get_xlim()
        self.original_ylim = ax.get_ylim()
        self.canvas.draw()

    @Slot()
    def onclick(self, event):
        ax = event.inaxes
        if ax is None:  
            return 0
        
        x, y = int(event.xdata), int(event.ydata)
        if event.button == 1:  
            if(self.clicked):
                ax.set_xlim(x - 10, x + 10)  
                ax.set_ylim( y + 50, y - 50)
                
            else:
                ax.set_xlim(x - 30, x + 30)  
                ax.set_ylim( y + 150, y - 150)
                self.clicked = True
                

        elif event.button == 3:
            ax.set_xlim(self.original_xlim)
            ax.set_ylim(self.original_ylim)
            self.clicked = False
        self.canvas.draw()

    def retranslateUi(self, Form):
        Form.setWindowTitle(QCoreApplication.translate("Form", u"Form", None))
        self.label.setText(QCoreApplication.translate("Form", u"Port", None))
        self.label_2.setText(QCoreApplication.translate("Form", u"Baudrate", None))
        self.pushButton.setText(QCoreApplication.translate("Form", u"Open", None))
        self.pushButton_2.setText(QCoreApplication.translate("Form", u"Close", None))
        self.pushButton_3.setText(QCoreApplication.translate("Form", u"Write", None))

    


class SerialMonitor(QWidget, Ui_Form):
    def __init__(self, parent=None):
        super(SerialMonitor, self).__init__()
        self.setupUi(self)
        buadrate_list = ["9600", "115200", "128000"]
        self.comboBox_2.addItems(buadrate_list)
        
        port_list = QSerialPortInfo().availablePorts()
        for i, port_info in enumerate(port_list):
            self.comboBox.insertItem(i, port_info.portName())

        self.dev = None
        self.receiver = Receiver(self)
        
        self.data = np.zeros((1024,100))
        self.data_idx = 0
        self.set_idx = 0
        #connect
        self.pushButton.clicked.connect(self.port_open)
        self.pushButton_2.clicked.connect(self.port_close)
        self.pushButton_3_1.clicked.connect(self.clear)
        self.pushButton_3.clicked.connect(self.serial_write)
        self.receiver.rx_data.connect(self.rx_data_append)

    @Slot()        
    def clear(self):
        self.textEdit.clear()

    @Slot()
    def port_open(self):
        current_port = self.comboBox.currentText()
        current_baudrate = int(self.comboBox_2.currentText())
        
        if self.dev is None or not self.dev.isOpen():
            try:
                self.dev = Serial(current_port, current_baudrate)
                self.receiver.start()
                self.textEdit.append("Device opened")
            except:
                self.textEdit.append("Failed to open the device")
        else:
            self.textEdit.append("Device already opened")

    @Slot()
    def port_close(self):
        if self.dev:
            if self.dev.is_open:
                self.receiver.is_running = False
                self.dev.close()
                self.dev = None
                self.textEdit.append("Device closed")
            else:
                self.textEdit.append("Already closed")
        else:
            self.textEdit.append("Already closed")
    
    @Slot()
    def serial_write(self):
        if self.dev:
            if self.dev.is_open:
                tx_msg = self.lineEdit.text()
                self.dev.write(tx_msg.encode('ascii'))
                self.textEdit.append("TX >> " + str(tx_msg.encode('ascii')))
                print(tx_msg.encode('ascii'))
            else:
                self.textEdit.append("Device closed")
        else:
            self.textEdit.append("Device closed")

    @Slot(bytes)        
    def rx_data_append(self, r_data):
        value = int.from_bytes(r_data, byteorder='big', signed=True)
        print(value)
        self.data[self.data_idx,self.set_idx] = value
        if self.data_idx == 1023:
            if self.set_idx == 99:
                self.set_idx = 0
                self.data_idx = 0
            else:
                self.set_idx = self.set_idx + 1
                self.data_idx = 0
            self.draw_heatmap(self.data)
        else:
            self.data_idx += 1
        
        

class Receiver(QThread):
    rx_data = Signal(bytes)
    def __init__(self, parent=None):
        super(Receiver,self).__init__(parent)
        self.serial_monitor = parent
        self.is_running = False
    
    def run(self):
        self.is_running = True
        while self.is_running:
            rx_msg = self.serial_monitor.dev.read(2)
            if rx_msg:
                self.rx_data.emit(rx_msg)
                

if __name__ == '__main__':
    app = QApplication()
    window = SerialMonitor()
    window.show()
    app.exec()
    
