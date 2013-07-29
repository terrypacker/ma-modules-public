package com.infiniteautomation.serial.vo;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.List;

import com.infiniteautomation.serial.rt.SerialDataSourceRT;
import com.serotonin.json.JsonException;
import com.serotonin.json.JsonReader;
import com.serotonin.json.ObjectWriter;
import com.serotonin.json.spi.JsonEntity;
import com.serotonin.json.spi.JsonProperty;
import com.serotonin.json.type.JsonObject;
import com.serotonin.m2m2.i18n.ProcessResult;
import com.serotonin.m2m2.i18n.TranslatableMessage;
import com.serotonin.m2m2.rt.dataSource.DataSourceRT;
import com.serotonin.m2m2.rt.event.type.AuditEventType;
import com.serotonin.m2m2.util.ExportCodes;
import com.serotonin.m2m2.vo.dataSource.DataSourceVO;
import com.serotonin.m2m2.vo.dataSource.PointLocatorVO;
import com.serotonin.m2m2.vo.event.EventTypeVO;
import com.serotonin.util.SerializationHelper;

@JsonEntity
public class SerialDataSourceVO extends DataSourceVO<SerialDataSourceVO>{
	
    private static final ExportCodes EVENT_CODES = new ExportCodes();

    @JsonProperty
    private String commPortId;
    @JsonProperty
    private int baudRate = 9600;
    @JsonProperty
    private int flowControlIn = 0;
    @JsonProperty
    private int flowControlOut = 0;
    @JsonProperty
    private int dataBits = 8;
    @JsonProperty
    private int stopBits = 1;
    @JsonProperty
    private int parity = 0;
    
	@Override
	public TranslatableMessage getConnectionDescription() {
		//TODO Flesh this out
		return new TranslatableMessage("serial.connection");
	}

	@Override
	public PointLocatorVO createPointLocator() {
		return new SerialPointLocatorVO();
	}

	@Override
	public DataSourceRT createDataSourceRT() {
		return new SerialDataSourceRT(this);
	}

	@Override
	public ExportCodes getEventCodes() {
		return EVENT_CODES;
	}

	@Override
	protected void addEventTypes(List<EventTypeVO> eventTypes) {
		// TODO Auto-generated method stub
		
	}
	public int getFlowControlMode() {
		return (this.getFlowControlIn() | this.getFlowControlOut());
	}

	public String getCommPortId() {
		return commPortId;
	}

	public void setCommPortId(String commPortId) {
		this.commPortId = commPortId;
	}

	public int getBaudRate() {
		return baudRate;
	}

	public void setBaudRate(int baudRate) {
		this.baudRate = baudRate;
	}

	public int getFlowControlIn() {
		return flowControlIn;
	}

	public void setFlowControlIn(int flowControlIn) {
		this.flowControlIn = flowControlIn;
	}

	public int getFlowControlOut() {
		return flowControlOut;
	}

	public void setFlowControlOut(int flowControlOut) {
		this.flowControlOut = flowControlOut;
	}

	public int getDataBits() {
		return dataBits;
	}

	public void setDataBits(int dataBits) {
		this.dataBits = dataBits;
	}

	public int getStopBits() {
		return stopBits;
	}

	public void setStopBits(int stopBits) {
		this.stopBits = stopBits;
	}

	public int getParity() {
		return parity;
	}

	public void setParity(int parity) {
		this.parity = parity;
	}
	
    @Override
    public void validate(ProcessResult response) {
        super.validate(response);
        if (isBlank(commPortId))
            response.addContextualMessage("commPortId", "validate.required");
        if (baudRate <= 0)
            response.addContextualMessage("baudRate", "validate.invalidValue");
        if (!(flowControlIn == 0 || flowControlIn == 1 || flowControlIn == 4))
            response.addContextualMessage("flowControlIn", "validate.invalidValue");
        if (!(flowControlOut == 0 || flowControlOut == 2 || flowControlOut == 8))
            response.addContextualMessage("flowControlOut", "validate.invalidValue");
        if (dataBits < 5 || dataBits > 8)
            response.addContextualMessage("dataBits", "validate.invalidValue");
        if (stopBits < 1 || stopBits > 3)
            response.addContextualMessage("stopBits", "validate.invalidValue");
        if (parity < 0 || parity > 4)
            response.addContextualMessage("parityBits", "validate.invalidValue");
     }

    @Override
    protected void addPropertiesImpl(List<TranslatableMessage> list) {
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.port", commPortId);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.baud", baudRate);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.flowControlIn", flowControlIn);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.flowControlOut", flowControlOut);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.dataBits", dataBits);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.stopBits", stopBits);
        AuditEventType.addPropertyMessage(list, "dsEdit.modbusSerial.parity", parity);
    }

    @Override
    protected void addPropertyChangesImpl(List<TranslatableMessage> list, SerialDataSourceVO from) {
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.port", from.commPortId, commPortId);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.baud", from.baudRate, baudRate);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.flowControlIn", from.flowControlIn,
                flowControlIn);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.flowControlOut", from.flowControlOut,
                flowControlOut);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.dataBits", from.dataBits, dataBits);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.stopBits", from.stopBits, stopBits);
        AuditEventType.maybeAddPropertyChangeMessage(list, "dsEdit.modbusSerial.parity", from.parity, parity);
    }

    //
    // /
    // / Serialization
    // /
    //
    private static final long serialVersionUID = -1;
    private static final int version = 1;

    private void writeObject(ObjectOutputStream out) throws IOException {
        out.writeInt(version);
        SerializationHelper.writeSafeUTF(out, commPortId);
        out.writeInt(baudRate);
        out.writeInt(flowControlIn);
        out.writeInt(flowControlOut);
        out.writeInt(dataBits);
        out.writeInt(stopBits);
        out.writeInt(parity);
    }

    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        int ver = in.readInt();

        // Switch on the version of the class so that version changes can be elegantly handled.
        if (ver == 1) {
            commPortId = SerializationHelper.readSafeUTF(in);
            baudRate = in.readInt();
            flowControlIn = in.readInt();
            flowControlOut = in.readInt();
            dataBits = in.readInt();
            stopBits = in.readInt();
            parity = in.readInt();
        }
    }

    @Override
    public void jsonWrite(ObjectWriter writer) throws IOException, JsonException {
        super.jsonWrite(writer);
    }

    @Override
    public void jsonRead(JsonReader reader, JsonObject jsonObject) throws JsonException {
        super.jsonRead(reader, jsonObject);
    }
	
	public boolean isBlank(CharSequence cs) {
		int strLen;
		if ((cs == null) || ((strLen = cs.length()) == 0))
			return true;

		for (int i = 0; i < strLen; ++i) {
			if (!(Character.isWhitespace(cs.charAt(i)))) {
				return false;
			}
		}
		return true;
	}
    
}