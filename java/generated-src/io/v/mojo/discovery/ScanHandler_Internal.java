// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is autogenerated by:
//     mojo/public/tools/bindings/mojom_bindings_generator.py
// For:
//     mojom/vanadium/discovery.mojom
//

package io.v.mojo.discovery;

class ScanHandler_Internal {

    public static final org.chromium.mojo.bindings.Interface.Manager<ScanHandler, ScanHandler.Proxy> MANAGER =
            new org.chromium.mojo.bindings.Interface.Manager<ScanHandler, ScanHandler.Proxy>() {
    
        public int getVersion() {
          return 0;
        }
    
        public Proxy buildProxy(org.chromium.mojo.system.Core core,
                                org.chromium.mojo.bindings.MessageReceiverWithResponder messageReceiver) {
            return new Proxy(core, messageReceiver);
        }
    
        public Stub buildStub(org.chromium.mojo.system.Core core, ScanHandler impl) {
            return new Stub(core, impl);
        }
    
        public ScanHandler[] buildArray(int size) {
          return new ScanHandler[size];
        }
    };

    private static final int ON_UPDATE_ORDINAL = 0;

    static final class Proxy extends org.chromium.mojo.bindings.Interface.AbstractProxy implements ScanHandler.Proxy {

        Proxy(org.chromium.mojo.system.Core core,
              org.chromium.mojo.bindings.MessageReceiverWithResponder messageReceiver) {
            super(core, messageReceiver);
        }

        @Override
        public void onUpdate(Update update) {
            ScanHandlerOnUpdateParams _message = new ScanHandlerOnUpdateParams();
            _message.update = update;
            getProxyHandler().getMessageReceiver().accept(
                    _message.serializeWithHeader(
                            getProxyHandler().getCore(),
                            new org.chromium.mojo.bindings.MessageHeader(ON_UPDATE_ORDINAL)));
        }

    }

    static final class Stub extends org.chromium.mojo.bindings.Interface.Stub<ScanHandler> {

        Stub(org.chromium.mojo.system.Core core, ScanHandler impl) {
            super(core, impl);
        }

        @Override
        public boolean accept(org.chromium.mojo.bindings.Message message) {
            try {
                org.chromium.mojo.bindings.ServiceMessage messageWithHeader =
                        message.asServiceMessage();
                org.chromium.mojo.bindings.MessageHeader header = messageWithHeader.getHeader();
                if (!header.validateHeader(org.chromium.mojo.bindings.MessageHeader.NO_FLAG)) {
                    return false;
                }
                switch(header.getType()) {
                    case org.chromium.mojo.bindings.InterfaceControlMessagesConstants.RUN_OR_CLOSE_PIPE_MESSAGE_ID:
                        return org.chromium.mojo.bindings.InterfaceControlMessagesHelper.handleRunOrClosePipe(
                                ScanHandler_Internal.MANAGER, messageWithHeader);
                    case ON_UPDATE_ORDINAL: {
                        ScanHandlerOnUpdateParams data =
                                ScanHandlerOnUpdateParams.deserialize(messageWithHeader.getPayload());
                        getImpl().onUpdate(data.update);
                        return true;
                    }
                    default:
                        return false;
                }
            } catch (org.chromium.mojo.bindings.DeserializationException e) {
                System.err.println(e.toString());
                return false;
            }
        }

        @Override
        public boolean acceptWithResponder(org.chromium.mojo.bindings.Message message, org.chromium.mojo.bindings.MessageReceiver receiver) {
            try {
                org.chromium.mojo.bindings.ServiceMessage messageWithHeader =
                        message.asServiceMessage();
                org.chromium.mojo.bindings.MessageHeader header = messageWithHeader.getHeader();
                if (!header.validateHeader(org.chromium.mojo.bindings.MessageHeader.MESSAGE_EXPECTS_RESPONSE_FLAG)) {
                    return false;
                }
                switch(header.getType()) {
                    case org.chromium.mojo.bindings.InterfaceControlMessagesConstants.RUN_MESSAGE_ID:
                        return org.chromium.mojo.bindings.InterfaceControlMessagesHelper.handleRun(
                                getCore(), ScanHandler_Internal.MANAGER, messageWithHeader, receiver);
                    default:
                        return false;
                }
            } catch (org.chromium.mojo.bindings.DeserializationException e) {
                System.err.println(e.toString());
                return false;
            }
        }
    }

    static final class ScanHandlerOnUpdateParams extends org.chromium.mojo.bindings.Struct {
    
        private static final int STRUCT_SIZE = 16;
        private static final org.chromium.mojo.bindings.DataHeader[] VERSION_ARRAY = new org.chromium.mojo.bindings.DataHeader[] {new org.chromium.mojo.bindings.DataHeader(16, 0)};
        private static final org.chromium.mojo.bindings.DataHeader DEFAULT_STRUCT_INFO = VERSION_ARRAY[0];
    
        public Update update;
    
        private ScanHandlerOnUpdateParams(int version) {
            super(STRUCT_SIZE, version);
        }
    
        public ScanHandlerOnUpdateParams() {
            this(0);
        }
    
        public static ScanHandlerOnUpdateParams deserialize(org.chromium.mojo.bindings.Message message) {
            return decode(new org.chromium.mojo.bindings.Decoder(message));
        }
    
        @SuppressWarnings("unchecked")
        public static ScanHandlerOnUpdateParams decode(org.chromium.mojo.bindings.Decoder decoder0) {
            if (decoder0 == null) {
                return null;
            }
            org.chromium.mojo.bindings.DataHeader mainDataHeader = decoder0.readAndValidateDataHeader(VERSION_ARRAY);
            ScanHandlerOnUpdateParams result = new ScanHandlerOnUpdateParams(mainDataHeader.elementsOrVersion);
            if (mainDataHeader.elementsOrVersion >= 0) {
                result.update = decoder0.readServiceInterface(8, false, Update.MANAGER);
            }
            return result;
        }
    
        @SuppressWarnings("unchecked")
        @Override
        protected final void encode(org.chromium.mojo.bindings.Encoder encoder) {
            org.chromium.mojo.bindings.Encoder encoder0 = encoder.getEncoderAtDataOffset(DEFAULT_STRUCT_INFO);
            encoder0.encode(update, 8, false, Update.MANAGER);
        }
    
        /**
         * @see Object#equals(Object)
         */
        @Override
        public boolean equals(Object object) {
            if (object == this)
                return true;
            if (object == null)
                return false;
            if (getClass() != object.getClass())
                return false;
            ScanHandlerOnUpdateParams other = (ScanHandlerOnUpdateParams) object;
            if (!org.chromium.mojo.bindings.BindingsHelper.equals(this.update, other.update))
                return false;
            return true;
        }
    
        /**
         * @see Object#hashCode()
         */
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = prime + getClass().hashCode();
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(update);
            return result;
        }
    }

}

