// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is autogenerated by:
//     mojo/public/tools/bindings/mojom_bindings_generator.py
// For:
//     mojom/vanadium/discovery.mojom
//

package io.v.mojo.discovery;

class Scanner_Internal {

    public static final org.chromium.mojo.bindings.Interface.NamedManager<Scanner, Scanner.Proxy> MANAGER =
            new org.chromium.mojo.bindings.Interface.NamedManager<Scanner, Scanner.Proxy>() {
    
        public String getName() {
            return "v23::discovery::Scanner";
        }
    
        public int getVersion() {
          return 0;
        }
    
        public Proxy buildProxy(org.chromium.mojo.system.Core core,
                                org.chromium.mojo.bindings.MessageReceiverWithResponder messageReceiver) {
            return new Proxy(core, messageReceiver);
        }
    
        public Stub buildStub(org.chromium.mojo.system.Core core, Scanner impl) {
            return new Stub(core, impl);
        }
    
        public Scanner[] buildArray(int size) {
          return new Scanner[size];
        }
    };

    private static final int SCAN_ORDINAL = 0;
    private static final int STOP_ORDINAL = 1;

    static final class Proxy extends org.chromium.mojo.bindings.Interface.AbstractProxy implements Scanner.Proxy {

        Proxy(org.chromium.mojo.system.Core core,
              org.chromium.mojo.bindings.MessageReceiverWithResponder messageReceiver) {
            super(core, messageReceiver);
        }

        @Override
        public void scan(String query, ScanHandler scanHandler, ScanResponse callback) {
            ScannerScanParams _message = new ScannerScanParams();
            _message.query = query;
            _message.scanHandler = scanHandler;
            getProxyHandler().getMessageReceiver().acceptWithResponder(
                    _message.serializeWithHeader(
                            getProxyHandler().getCore(),
                            new org.chromium.mojo.bindings.MessageHeader(
                                    SCAN_ORDINAL,
                                    org.chromium.mojo.bindings.MessageHeader.MESSAGE_EXPECTS_RESPONSE_FLAG,
                                    0)),
                    new ScannerScanResponseParamsForwardToCallback(callback));
        }

        @Override
        public void stop(int h, StopResponse callback) {
            ScannerStopParams _message = new ScannerStopParams();
            _message.h = h;
            getProxyHandler().getMessageReceiver().acceptWithResponder(
                    _message.serializeWithHeader(
                            getProxyHandler().getCore(),
                            new org.chromium.mojo.bindings.MessageHeader(
                                    STOP_ORDINAL,
                                    org.chromium.mojo.bindings.MessageHeader.MESSAGE_EXPECTS_RESPONSE_FLAG,
                                    0)),
                    new ScannerStopResponseParamsForwardToCallback(callback));
        }

    }

    static final class Stub extends org.chromium.mojo.bindings.Interface.Stub<Scanner> {

        Stub(org.chromium.mojo.system.Core core, Scanner impl) {
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
                                Scanner_Internal.MANAGER, messageWithHeader);
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
                                getCore(), Scanner_Internal.MANAGER, messageWithHeader, receiver);
                    case SCAN_ORDINAL: {
                        ScannerScanParams data =
                                ScannerScanParams.deserialize(messageWithHeader.getPayload());
                        getImpl().scan(data.query, data.scanHandler, new ScannerScanResponseParamsProxyToResponder(getCore(), receiver, header.getRequestId()));
                        return true;
                    }
                    case STOP_ORDINAL: {
                        ScannerStopParams data =
                                ScannerStopParams.deserialize(messageWithHeader.getPayload());
                        getImpl().stop(data.h, new ScannerStopResponseParamsProxyToResponder(getCore(), receiver, header.getRequestId()));
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
    }

    static final class ScannerScanParams extends org.chromium.mojo.bindings.Struct {
    
        private static final int STRUCT_SIZE = 24;
        private static final org.chromium.mojo.bindings.DataHeader[] VERSION_ARRAY = new org.chromium.mojo.bindings.DataHeader[] {new org.chromium.mojo.bindings.DataHeader(24, 0)};
        private static final org.chromium.mojo.bindings.DataHeader DEFAULT_STRUCT_INFO = VERSION_ARRAY[0];
    
        public String query;
        public ScanHandler scanHandler;
    
        private ScannerScanParams(int version) {
            super(STRUCT_SIZE, version);
        }
    
        public ScannerScanParams() {
            this(0);
        }
    
        public static ScannerScanParams deserialize(org.chromium.mojo.bindings.Message message) {
            return decode(new org.chromium.mojo.bindings.Decoder(message));
        }
    
        @SuppressWarnings("unchecked")
        public static ScannerScanParams decode(org.chromium.mojo.bindings.Decoder decoder0) {
            if (decoder0 == null) {
                return null;
            }
            org.chromium.mojo.bindings.DataHeader mainDataHeader = decoder0.readAndValidateDataHeader(VERSION_ARRAY);
            ScannerScanParams result = new ScannerScanParams(mainDataHeader.elementsOrVersion);
            if (mainDataHeader.elementsOrVersion >= 0) {
                result.query = decoder0.readString(8, false);
            }
            if (mainDataHeader.elementsOrVersion >= 0) {
                result.scanHandler = decoder0.readServiceInterface(16, false, ScanHandler.MANAGER);
            }
            return result;
        }
    
        @SuppressWarnings("unchecked")
        @Override
        protected final void encode(org.chromium.mojo.bindings.Encoder encoder) {
            org.chromium.mojo.bindings.Encoder encoder0 = encoder.getEncoderAtDataOffset(DEFAULT_STRUCT_INFO);
            encoder0.encode(query, 8, false);
            encoder0.encode(scanHandler, 16, false, ScanHandler.MANAGER);
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
            ScannerScanParams other = (ScannerScanParams) object;
            if (!org.chromium.mojo.bindings.BindingsHelper.equals(this.query, other.query))
                return false;
            if (!org.chromium.mojo.bindings.BindingsHelper.equals(this.scanHandler, other.scanHandler))
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
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(query);
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(scanHandler);
            return result;
        }
    }

    static final class ScannerScanResponseParams extends org.chromium.mojo.bindings.Struct {
    
        private static final int STRUCT_SIZE = 24;
        private static final org.chromium.mojo.bindings.DataHeader[] VERSION_ARRAY = new org.chromium.mojo.bindings.DataHeader[] {new org.chromium.mojo.bindings.DataHeader(24, 0)};
        private static final org.chromium.mojo.bindings.DataHeader DEFAULT_STRUCT_INFO = VERSION_ARRAY[0];
    
        public int handle;
        public Error err;
    
        private ScannerScanResponseParams(int version) {
            super(STRUCT_SIZE, version);
        }
    
        public ScannerScanResponseParams() {
            this(0);
        }
    
        public static ScannerScanResponseParams deserialize(org.chromium.mojo.bindings.Message message) {
            return decode(new org.chromium.mojo.bindings.Decoder(message));
        }
    
        @SuppressWarnings("unchecked")
        public static ScannerScanResponseParams decode(org.chromium.mojo.bindings.Decoder decoder0) {
            if (decoder0 == null) {
                return null;
            }
            org.chromium.mojo.bindings.DataHeader mainDataHeader = decoder0.readAndValidateDataHeader(VERSION_ARRAY);
            ScannerScanResponseParams result = new ScannerScanResponseParams(mainDataHeader.elementsOrVersion);
            if (mainDataHeader.elementsOrVersion >= 0) {
                result.handle = decoder0.readInt(8);
            }
            if (mainDataHeader.elementsOrVersion >= 0) {
                org.chromium.mojo.bindings.Decoder decoder1 = decoder0.readPointer(16, true);
                result.err = Error.decode(decoder1);
            }
            return result;
        }
    
        @SuppressWarnings("unchecked")
        @Override
        protected final void encode(org.chromium.mojo.bindings.Encoder encoder) {
            org.chromium.mojo.bindings.Encoder encoder0 = encoder.getEncoderAtDataOffset(DEFAULT_STRUCT_INFO);
            encoder0.encode(handle, 8);
            encoder0.encode(err, 16, true);
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
            ScannerScanResponseParams other = (ScannerScanResponseParams) object;
            if (this.handle != other.handle)
                return false;
            if (!org.chromium.mojo.bindings.BindingsHelper.equals(this.err, other.err))
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
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(handle);
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(err);
            return result;
        }
    }

    static class ScannerScanResponseParamsForwardToCallback extends org.chromium.mojo.bindings.SideEffectFreeCloseable
            implements org.chromium.mojo.bindings.MessageReceiver {
        private final Scanner.ScanResponse mCallback;

        ScannerScanResponseParamsForwardToCallback(Scanner.ScanResponse callback) {
            this.mCallback = callback;
        }

        @Override
        public boolean accept(org.chromium.mojo.bindings.Message message) {
            try {
                org.chromium.mojo.bindings.ServiceMessage messageWithHeader =
                        message.asServiceMessage();
                org.chromium.mojo.bindings.MessageHeader header = messageWithHeader.getHeader();
                if (!header.validateHeader(SCAN_ORDINAL,
                                           org.chromium.mojo.bindings.MessageHeader.MESSAGE_IS_RESPONSE_FLAG)) {
                    return false;
                }
                ScannerScanResponseParams response = ScannerScanResponseParams.deserialize(messageWithHeader.getPayload());
                mCallback.call(response.handle, response.err);
                return true;
            } catch (org.chromium.mojo.bindings.DeserializationException e) {
                return false;
            }
        }
    }

    static class ScannerScanResponseParamsProxyToResponder implements Scanner.ScanResponse {

        private final org.chromium.mojo.system.Core mCore;
        private final org.chromium.mojo.bindings.MessageReceiver mMessageReceiver;
        private final long mRequestId;

        ScannerScanResponseParamsProxyToResponder(
                org.chromium.mojo.system.Core core,
                org.chromium.mojo.bindings.MessageReceiver messageReceiver,
                long requestId) {
            mCore = core;
            mMessageReceiver = messageReceiver;
            mRequestId = requestId;
        }

        @Override
        public void call(Integer handle, Error err) {
            ScannerScanResponseParams _response = new ScannerScanResponseParams();
            _response.handle = handle;
            _response.err = err;
            org.chromium.mojo.bindings.ServiceMessage _message =
                    _response.serializeWithHeader(
                            mCore,
                            new org.chromium.mojo.bindings.MessageHeader(
                                    SCAN_ORDINAL,
                                    org.chromium.mojo.bindings.MessageHeader.MESSAGE_IS_RESPONSE_FLAG,
                                    mRequestId));
            mMessageReceiver.accept(_message);
        }
    }

    static final class ScannerStopParams extends org.chromium.mojo.bindings.Struct {
    
        private static final int STRUCT_SIZE = 16;
        private static final org.chromium.mojo.bindings.DataHeader[] VERSION_ARRAY = new org.chromium.mojo.bindings.DataHeader[] {new org.chromium.mojo.bindings.DataHeader(16, 0)};
        private static final org.chromium.mojo.bindings.DataHeader DEFAULT_STRUCT_INFO = VERSION_ARRAY[0];
    
        public int h;
    
        private ScannerStopParams(int version) {
            super(STRUCT_SIZE, version);
        }
    
        public ScannerStopParams() {
            this(0);
        }
    
        public static ScannerStopParams deserialize(org.chromium.mojo.bindings.Message message) {
            return decode(new org.chromium.mojo.bindings.Decoder(message));
        }
    
        @SuppressWarnings("unchecked")
        public static ScannerStopParams decode(org.chromium.mojo.bindings.Decoder decoder0) {
            if (decoder0 == null) {
                return null;
            }
            org.chromium.mojo.bindings.DataHeader mainDataHeader = decoder0.readAndValidateDataHeader(VERSION_ARRAY);
            ScannerStopParams result = new ScannerStopParams(mainDataHeader.elementsOrVersion);
            if (mainDataHeader.elementsOrVersion >= 0) {
                result.h = decoder0.readInt(8);
            }
            return result;
        }
    
        @SuppressWarnings("unchecked")
        @Override
        protected final void encode(org.chromium.mojo.bindings.Encoder encoder) {
            org.chromium.mojo.bindings.Encoder encoder0 = encoder.getEncoderAtDataOffset(DEFAULT_STRUCT_INFO);
            encoder0.encode(h, 8);
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
            ScannerStopParams other = (ScannerStopParams) object;
            if (this.h != other.h)
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
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(h);
            return result;
        }
    }

    static final class ScannerStopResponseParams extends org.chromium.mojo.bindings.Struct {
    
        private static final int STRUCT_SIZE = 16;
        private static final org.chromium.mojo.bindings.DataHeader[] VERSION_ARRAY = new org.chromium.mojo.bindings.DataHeader[] {new org.chromium.mojo.bindings.DataHeader(16, 0)};
        private static final org.chromium.mojo.bindings.DataHeader DEFAULT_STRUCT_INFO = VERSION_ARRAY[0];
    
        public Error err;
    
        private ScannerStopResponseParams(int version) {
            super(STRUCT_SIZE, version);
        }
    
        public ScannerStopResponseParams() {
            this(0);
        }
    
        public static ScannerStopResponseParams deserialize(org.chromium.mojo.bindings.Message message) {
            return decode(new org.chromium.mojo.bindings.Decoder(message));
        }
    
        @SuppressWarnings("unchecked")
        public static ScannerStopResponseParams decode(org.chromium.mojo.bindings.Decoder decoder0) {
            if (decoder0 == null) {
                return null;
            }
            org.chromium.mojo.bindings.DataHeader mainDataHeader = decoder0.readAndValidateDataHeader(VERSION_ARRAY);
            ScannerStopResponseParams result = new ScannerStopResponseParams(mainDataHeader.elementsOrVersion);
            if (mainDataHeader.elementsOrVersion >= 0) {
                org.chromium.mojo.bindings.Decoder decoder1 = decoder0.readPointer(8, true);
                result.err = Error.decode(decoder1);
            }
            return result;
        }
    
        @SuppressWarnings("unchecked")
        @Override
        protected final void encode(org.chromium.mojo.bindings.Encoder encoder) {
            org.chromium.mojo.bindings.Encoder encoder0 = encoder.getEncoderAtDataOffset(DEFAULT_STRUCT_INFO);
            encoder0.encode(err, 8, true);
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
            ScannerStopResponseParams other = (ScannerStopResponseParams) object;
            if (!org.chromium.mojo.bindings.BindingsHelper.equals(this.err, other.err))
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
            result = prime * result + org.chromium.mojo.bindings.BindingsHelper.hashCode(err);
            return result;
        }
    }

    static class ScannerStopResponseParamsForwardToCallback extends org.chromium.mojo.bindings.SideEffectFreeCloseable
            implements org.chromium.mojo.bindings.MessageReceiver {
        private final Scanner.StopResponse mCallback;

        ScannerStopResponseParamsForwardToCallback(Scanner.StopResponse callback) {
            this.mCallback = callback;
        }

        @Override
        public boolean accept(org.chromium.mojo.bindings.Message message) {
            try {
                org.chromium.mojo.bindings.ServiceMessage messageWithHeader =
                        message.asServiceMessage();
                org.chromium.mojo.bindings.MessageHeader header = messageWithHeader.getHeader();
                if (!header.validateHeader(STOP_ORDINAL,
                                           org.chromium.mojo.bindings.MessageHeader.MESSAGE_IS_RESPONSE_FLAG)) {
                    return false;
                }
                ScannerStopResponseParams response = ScannerStopResponseParams.deserialize(messageWithHeader.getPayload());
                mCallback.call(response.err);
                return true;
            } catch (org.chromium.mojo.bindings.DeserializationException e) {
                return false;
            }
        }
    }

    static class ScannerStopResponseParamsProxyToResponder implements Scanner.StopResponse {

        private final org.chromium.mojo.system.Core mCore;
        private final org.chromium.mojo.bindings.MessageReceiver mMessageReceiver;
        private final long mRequestId;

        ScannerStopResponseParamsProxyToResponder(
                org.chromium.mojo.system.Core core,
                org.chromium.mojo.bindings.MessageReceiver messageReceiver,
                long requestId) {
            mCore = core;
            mMessageReceiver = messageReceiver;
            mRequestId = requestId;
        }

        @Override
        public void call(Error err) {
            ScannerStopResponseParams _response = new ScannerStopResponseParams();
            _response.err = err;
            org.chromium.mojo.bindings.ServiceMessage _message =
                    _response.serializeWithHeader(
                            mCore,
                            new org.chromium.mojo.bindings.MessageHeader(
                                    STOP_ORDINAL,
                                    org.chromium.mojo.bindings.MessageHeader.MESSAGE_IS_RESPONSE_FLAG,
                                    mRequestId));
            mMessageReceiver.accept(_message);
        }
    }

}

