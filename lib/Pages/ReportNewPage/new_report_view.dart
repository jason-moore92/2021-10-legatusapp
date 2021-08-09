import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legutus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Helpers/validators.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/Dialogs/success_dialog.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info/device_info.dart';

class NewReportView extends StatefulWidget {
  final bool? isNew;
  final LocalReportModel? localReportModel;

  NewReportView({Key? key, this.isNew, this.localReportModel}) : super(key: key);

  @override
  _NewReportViewState createState() => _NewReportViewState();
}

class _NewReportViewState extends State<NewReportView> with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  ///////////////////////////////

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _dateFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();

  TextEditingController _streetController = TextEditingController();
  TextEditingController _addressComplementController = TextEditingController();
  TextEditingController _zipController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();

  FocusNode _streetFocusNode = FocusNode();
  FocusNode _addressComplementFocusNode = FocusNode();
  FocusNode _zipFocusNode = FocusNode();
  FocusNode _cityFocusNode = FocusNode();
  FocusNode _latitudeFocusNode = FocusNode();
  FocusNode _longitudeFocusNode = FocusNode();

  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _customerStreetController = TextEditingController();
  TextEditingController _customerComplementController = TextEditingController();
  TextEditingController _customerZipController = TextEditingController();
  TextEditingController _customerCityController = TextEditingController();
  TextEditingController _cropFormController = TextEditingController();
  TextEditingController _cropSirenController = TextEditingController();
  TextEditingController _cropRCSController = TextEditingController();

  FocusNode _customerNameFocusNode = FocusNode();
  FocusNode _customerStreetFocusNode = FocusNode();
  FocusNode _customerComplementFocusNode = FocusNode();
  FocusNode _customerZipFocusNode = FocusNode();
  FocusNode _customerCityFocusNode = FocusNode();
  FocusNode _cropFromFocusNode = FocusNode();
  FocusNode _cropSirenFocusNode = FocusNode();
  FocusNode _cropRCSFocusNode = FocusNode();

  TextEditingController _recipientNameController = TextEditingController();
  TextEditingController _recipientPositionController = TextEditingController();
  TextEditingController _recipientBirthDayController = TextEditingController();
  TextEditingController _recipientBirthCityController = TextEditingController();
  TextEditingController _recipientEmailController = TextEditingController();
  TextEditingController _recipientPhoneNumberController = TextEditingController();

  FocusNode _recipientNameFocusNode = FocusNode();
  FocusNode _recipientPositionFocusNode = FocusNode();
  FocusNode _recipientBirthDayFocusNode = FocusNode();
  FocusNode _recipientBirthCityFocusNode = FocusNode();
  FocusNode _recipientEmailFocusNode = FocusNode();
  FocusNode _recipientPhoneNumberFocusNode = FocusNode();

  LocalReportModel? _localReportModel;

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _init = false;
  bool? _isNew;

  LocalReportProvider? _localReportProvider;
  KeicyProgressDialog? _keicyProgressDialog;

  DateTime? _reportDateTime;
  DateTime? _recipientBirthDateTime;

  Map<String, dynamic> _updatedStatus = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    bottomBarHeight = ScreenUtil().bottomBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    _localReportProvider = LocalReportProvider.of(context);
    _keicyProgressDialog = KeicyProgressDialog.of(
      context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      layout: Layout.Column,
      padding: EdgeInsets.zero,
      width: heightDp! * 120,
      height: heightDp! * 120,
      progressWidget: Container(
        width: heightDp! * 120,
        height: heightDp! * 120,
        padding: EdgeInsets.all(heightDp! * 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(heightDp! * 10),
        ),
        child: SpinKitFadingCircle(
          color: AppColors.primayColor,
          size: heightDp! * 80,
        ),
      ),
      message: "",
    );

    _localReportProvider!.setLocalReportState(
      LocalReportState.init().copyWith(contextName: "NewReportPage"),
      isNotifiable: false,
    );

    _isNew = widget.isNew!;

    _localReportModel = widget.localReportModel != null ? LocalReportModel.copy(widget.localReportModel!) : LocalReportModel();

    if (_isNew!) {
      _reportDateTime = DateTime.now();

      _dateController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime, formats: "d/m/Y");
      _timeController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: 'H:i:s');
    } else {
      _reportDateTime = KeicyDateTime.convertDateStringToDateTime(dateString: _localReportModel!.date!);
      if (_localReportModel!.recipientBirthDate != "") {
        _recipientBirthDateTime = KeicyDateTime.convertDateStringToDateTime(dateString: _localReportModel!.recipientBirthDate!);
      } else {}

      _nameController.text = _localReportModel!.name!;
      _dateController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime, formats: "d/m/Y");
      _timeController.text = _localReportModel!.time!;
      _descriptionController.text = _localReportModel!.description!;

      _streetController.text = _localReportModel!.street!;
      _addressComplementController.text = _localReportModel!.complement!;
      _zipController.text = _localReportModel!.zip!;
      _cityController.text = _localReportModel!.city!;
      _latitudeController.text = _localReportModel!.latitude!;
      _longitudeController.text = _localReportModel!.longitude!;

      _customerNameController.text = _localReportModel!.customerName!;
      _customerStreetController.text = _localReportModel!.customerStreet!;
      _customerComplementController.text = _localReportModel!.customerComplement!;
      _customerZipController.text = _localReportModel!.customerZip!;
      _customerCityController.text = _localReportModel!.customerCity!;
      _cropFormController.text = _localReportModel!.customerCorpForm!;
      _cropSirenController.text = _localReportModel!.customerCorpSiren!;
      _cropRCSController.text = _localReportModel!.customerCorpRcs!;

      _recipientNameController.text = _localReportModel!.recipientName!;
      _recipientPositionController.text = _localReportModel!.recipientPosition!;
      _recipientBirthDayController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _recipientBirthDateTime, formats: "d/m/Y");
      _recipientBirthCityController.text = _localReportModel!.recipientBirthCity!;
      _recipientEmailController.text = _localReportModel!.recipientEmail!;
      _recipientPhoneNumberController.text = _localReportModel!.recipientPhone!;
    }

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _localReportProvider!.addListener(_localReportProviderListener);
    });
  }

  @override
  void dispose() {
    _localReportProvider!.removeListener(_localReportProviderListener);

    super.dispose();
  }

  void _localReportProviderListener() async {
    if (_localReportProvider!.localReportState.contextName != "NewReportPage") return;

    if (_localReportProvider!.localReportState.progressState != 1 && _keicyProgressDialog!.isShowing()) {
      await _keicyProgressDialog!.hide();
    }

    if (_localReportProvider!.localReportState.progressState == 2) {
      SuccessDialog.show(
        context,
        text: _isNew! ? LocaleKeys.NewReportPageString_createSuccess.tr() : LocaleKeys.NewReportPageString_updateSuccess.tr(),
        callBack: () {
          Navigator.of(context).pop(_updatedStatus);
        },
      );

      if (_isNew!) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
        _isNew = false;
      } else {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
      }
      setState(() {});
    } else if (_localReportProvider!.localReportState.progressState == -1) {
      FailedDialog.show(context, text: _localReportProvider!.localReportState.message!);
    }
  }

  void _createHandler() async {
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();

    FocusScope.of(context).requestFocus(FocusNode());

    await _keicyProgressDialog!.show();

    if (_isNew!) {
      _localReportModel!.uuid = Uuid().v4();
      _localReportModel!.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");

      if (Platform.isAndroid) {
        _localReportModel!.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
      } else if (Platform.isAndroid) {
        _localReportModel!.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
      }
      // _localReportModel!.reportId = DateTime.now().millisecondsSinceEpoch;

      _localReportProvider!.createLocalReport(
        localReportModel: _localReportModel,
      );
    } else {
      String reportId = KeicyDateTime.convertDateStringToMilliseconds(dateString: _localReportModel!.createdAt).toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString: "${widget.localReportModel!.date} ${widget.localReportModel!.time}",
      )!;
      _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportId: "${reportDateTime}_$reportId",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_updatedStatus);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop(_updatedStatus);
            },
          ),
          title: Text(
            LocaleKeys.NewReportPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: _isNew! && _init == false
            ? FutureBuilder<LocationPermission>(
                future: Geolocator.checkPermission(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return Center(child: CupertinoActivityIndicator());
                    case ConnectionState.done:
                      _init = true;
                      if (snapshot.hasData && (snapshot.data == LocationPermission.whileInUse || snapshot.data == LocationPermission.always)) {
                        return FutureBuilder<Position>(
                            future: Geolocator.getCurrentPosition(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  return Center(child: CupertinoActivityIndicator());
                                case ConnectionState.done:
                                  if (snapshot.hasData && snapshot.data != null) {
                                    _latitudeController.text = snapshot.data!.latitude.toString();
                                    _longitudeController.text = snapshot.data!.longitude.toString();
                                  }
                                  return _mainPanel();
                                default:
                              }

                              return Center(child: CupertinoActivityIndicator());
                            });
                      } else {
                        return _mainPanel();
                      }
                    default:
                  }
                  return Center(child: CupertinoActivityIndicator());
                },
              )
            : _mainPanel(),
      ),
    );
  }

  Widget _mainPanel() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowGlow();
        return true;
      },
      child: SingleChildScrollView(
        child: Container(
          width: deviceWidth,
          padding: EdgeInsets.symmetric(vertical: heightDp! * 20),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 15),
                  child: _reportPanel(),
                ),

                Divider(height: heightDp! * 30, thickness: 1, color: Colors.grey.withOpacity(0.6)),

                ///
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 15),
                  child: _addressPanel(),
                ),
                SizedBox(height: heightDp! * 15),
                Divider(height: heightDp! * 1, thickness: 1, color: Colors.grey.withOpacity(0.6)),
                _customerPaner(),

                Divider(height: heightDp! * 30, thickness: 1, color: Colors.grey.withOpacity(0.6)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 15),
                  child: _recipientPanel(),
                ),

                ///
                SizedBox(height: heightDp! * 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      text: LocaleKeys.NewReportPageString_save.tr().toUpperCase(),
                      textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                      backColor: AppColors.yello,
                      onPressed: _createHandler,
                    ),
                    SizedBox(width: widthDp! * 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportPanel() {
    Map<String, dynamic> typeData = json.decode(LocaleKeys.NewReportPageString_types.tr());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_reportName.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              "  *",
              style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: LocaleKeys.NewReportPageString_reportName.tr(),
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          validator: (input) => input.isEmpty
              ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(
                  args: [LocaleKeys.NewReportPageString_name.tr()],
                )
              : null,
          onSaved: (input) => _localReportModel!.name = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
          onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
        ),

        ///
        SizedBox(height: heightDp! * 5),
        Wrap(
          children: List.generate(typeData.length, (index) {
            String type = typeData.keys.toList()[index];
            String label = typeData[type];

            if (_localReportModel!.type == "") _localReportModel!.type = type;

            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Radio<String>(
                  value: type,
                  groupValue: _localReportModel!.type ?? "",
                  activeColor: AppColors.yello,
                  onChanged: (String? value) {
                    _localReportModel!.type = value;
                    setState(() {});
                  },
                ),
                Text(label, style: Theme.of(context).textTheme.caption)
              ],
            );
          }),
        ),

        ///
        SizedBox(height: heightDp! * 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_date.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        "  *",
                        style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _dateController,
                    focusNode: _dateFocusNode,
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskTextInputFormatter(mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')})
                    ],
                    readOnly: true,
                    onTap: () async {
                      DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );

                      if (dateTime != null) {
                        _reportDateTime = dateTime;
                        _dateController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime, formats: "d/m/Y");
                      }
                    },
                    validator: (input) => input.isEmpty
                        ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
                        : input.length != 10
                            ? LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
                            : null,
                    onChanged: (input) => (input.length == 10) ? FocusScope.of(context).requestFocus(_timeFocusNode) : null,
                    onSaved: (input) => _localReportModel!.date = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime),
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_timeFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_timeFocusNode),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 10),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_time.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        "  *",
                        style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _timeController,
                    focusNode: _timeFocusNode,
                    hintText: "10:00",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskTextInputFormatter(mask: '##:##:##', filter: {"#": RegExp(r'[0-9]')})
                    ],
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                      if (timeOfDay != null) {
                        _timeController.text = KeicyDateTime.convertDateTimeToDateString(
                          dateTime: DateTime(2000, 1, 1, timeOfDay.hour, timeOfDay.minute),
                          formats: 'H:i:s',
                        );
                      }
                    },
                    validator: (input) => input.isEmpty
                        ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: [LocaleKeys.NewReportPageString_time.tr().toLowerCase()])
                        : input.length != 8
                            ? LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(args: [LocaleKeys.NewReportPageString_time.tr().toLowerCase()])
                            : null,
                    onSaved: (input) => _localReportModel!.time = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                  ),
                ],
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_description.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          hintText: LocaleKeys.NewReportPageString_description.tr(),
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          onSaved: (input) => _localReportModel!.description = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
          onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
        ),
      ],
    );
  }

  Widget _addressPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.NewReportPageString_addressLabel.tr(),
          style: Theme.of(context).textTheme.caption,
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_street.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _streetController,
          focusNode: _streetFocusNode,
          hintText: "129 rue vauban",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          onSaved: (input) => _localReportModel!.street = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_addressComplementFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_addressComplementFocusNode),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_additionalAddress.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _addressComplementController,
          focusNode: _addressComplementFocusNode,
          hintText: "Immeuble le Radiant",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          onSaved: (input) => _localReportModel!.complement = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_zipFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_zipFocusNode),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_zip.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _zipController,
                    focusNode: _zipFocusNode,
                    hintText: "69006",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (input) => _localReportModel!.zip = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_cityFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_cityFocusNode),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 10),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_city.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _cityController,
                    focusNode: _cityFocusNode,
                    hintText: "Lyon",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    onSaved: (input) => _localReportModel!.city = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_latitudeFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_latitudeFocusNode),
                  ),
                ],
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_latitude.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _latitudeController,
                    focusNode: _latitudeFocusNode,
                    hintText: "45.76543212",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (input) => _localReportModel!.latitude = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_longitudeFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_longitudeFocusNode),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 10),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_longitude.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _longitudeController,
                    focusNode: _longitudeFocusNode,
                    hintText: "4.98346523",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (input) => _localReportModel!.longitude = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _customerPaner() {
    Map<String, dynamic> customerTypes = json.decode(LocaleKeys.NewReportPageString_customerTypes.tr());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: widthDp! * 15),
            Text(LocaleKeys.NewReportPageString_customerTypeLabel.tr(), style: Theme.of(context).textTheme.caption),
            Expanded(
              child: Wrap(
                children: List.generate(customerTypes.length, (index) {
                  String type = customerTypes.keys.toList()[index];
                  String label = customerTypes[type];

                  if (_localReportModel!.customerType == "") _localReportModel!.customerType = type;

                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Radio<String>(
                        value: type,
                        groupValue: _localReportModel!.customerType ?? "",
                        activeColor: AppColors.yello,
                        onChanged: (String? value) {
                          _localReportModel!.customerType = value;
                          setState(() {});
                        },
                      ),
                      Text(label, style: Theme.of(context).textTheme.caption)
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widthDp! * 15),
          child: Column(
            children: [
              ///
              Row(
                children: [
                  Text(
                    LocaleKeys.NewReportPageString_name.tr(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  // Text(
                  //   "  *",
                  //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                  // ),
                ],
              ),
              SizedBox(height: heightDp! * 5),
              CustomTextFormField(
                controller: _customerNameController,
                focusNode: _customerNameFocusNode,
                hintText: LocaleKeys.NewReportPageString_name.tr(),
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(heightDp! * 6),
                ),
                onSaved: (input) => _localReportModel!.customerName = input,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_customerStreetFocusNode),
                onEditingComplete: () => FocusScope.of(context).requestFocus(_customerStreetFocusNode),
              ),

              ///
              ///
              SizedBox(height: heightDp! * 10),
              Row(
                children: [
                  Text(
                    LocaleKeys.NewReportPageString_street.tr(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  // Text(
                  //   "  *",
                  //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                  // ),
                ],
              ),
              SizedBox(height: heightDp! * 5),
              CustomTextFormField(
                controller: _customerStreetController,
                focusNode: _customerStreetFocusNode,
                hintText: "78 boulevard du 11 Novembre 1918",
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(heightDp! * 6),
                ),
                onSaved: (input) => _localReportModel!.customerStreet = input,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_customerComplementFocusNode),
                onEditingComplete: () => FocusScope.of(context).requestFocus(_customerComplementFocusNode),
              ),

              ///
              SizedBox(height: heightDp! * 10),
              Row(
                children: [
                  Text(
                    LocaleKeys.NewReportPageString_additionalAddress.tr(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  // Text(
                  //   "  *",
                  //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                  // ),
                ],
              ),
              SizedBox(height: heightDp! * 5),
              CustomTextFormField(
                controller: _customerComplementController,
                focusNode: _customerComplementFocusNode,
                hintText: "Immeuble le Radiant",
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(heightDp! * 6),
                ),
                onSaved: (input) => _localReportModel!.customerComplement = input,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_customerZipFocusNode),
                onEditingComplete: () => FocusScope.of(context).requestFocus(_customerZipFocusNode),
              ),

              ///
              SizedBox(height: heightDp! * 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              LocaleKeys.NewReportPageString_zip.tr(),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            // Text(
                            //   "  *",
                            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                            // ),
                          ],
                        ),
                        SizedBox(height: heightDp! * 5),
                        CustomTextFormField(
                          controller: _customerZipController,
                          focusNode: _customerZipFocusNode,
                          hintText: "69006",
                          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(heightDp! * 6),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSaved: (input) => _localReportModel!.customerZip = input,
                          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_customerCityFocusNode),
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_customerCityFocusNode),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: widthDp! * 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              LocaleKeys.NewReportPageString_city.tr(),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            // Text(
                            //   "  *",
                            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                            // ),
                          ],
                        ),
                        SizedBox(height: heightDp! * 5),
                        CustomTextFormField(
                          controller: _customerCityController,
                          focusNode: _customerCityFocusNode,
                          hintText: "Lyon",
                          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(heightDp! * 6),
                          ),
                          onSaved: (input) => _localReportModel!.customerCity = input,
                          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_cropFromFocusNode),
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_cropFromFocusNode),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              ///
              SizedBox(height: heightDp! * 10),
              Row(
                children: [
                  Text(
                    LocaleKeys.NewReportPageString_crop_form.tr(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  // Text(
                  //   "  *",
                  //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                  // ),
                ],
              ),
              SizedBox(height: heightDp! * 5),
              CustomTextFormField(
                controller: _cropFormController,
                focusNode: _cropFromFocusNode,
                hintText: LocaleKeys.NewReportPageString_crop_form.tr(),
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(heightDp! * 6),
                ),
                onSaved: (input) => _localReportModel!.customerCorpForm = input,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_cropSirenFocusNode),
                onEditingComplete: () => FocusScope.of(context).requestFocus(_cropSirenFocusNode),
              ),

              ///
              SizedBox(height: heightDp! * 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              LocaleKeys.NewReportPageString_crop_siren.tr(),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            // Text(
                            //   "  *",
                            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                            // ),
                          ],
                        ),
                        SizedBox(height: heightDp! * 5),
                        CustomTextFormField(
                          controller: _cropSirenController,
                          focusNode: _cropSirenFocusNode,
                          hintText: LocaleKeys.NewReportPageString_crop_siren.tr(),
                          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(heightDp! * 6),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSaved: (input) => _localReportModel!.customerCorpSiren = input,
                          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_cropRCSFocusNode),
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_cropRCSFocusNode),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: widthDp! * 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              LocaleKeys.NewReportPageString_crop_rcs.tr(),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            // Text(
                            //   "  *",
                            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                            // ),
                          ],
                        ),
                        SizedBox(height: heightDp! * 5),
                        CustomTextFormField(
                          controller: _cropRCSController,
                          focusNode: _cropRCSFocusNode,
                          hintText: LocaleKeys.NewReportPageString_crop_rcs.tr(),
                          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(heightDp! * 6),
                          ),
                          onSaved: (input) => _localReportModel!.customerCorpRcs = input,
                          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                          onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recipientPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.NewReportPageString_recipient_label.tr(),
          style: Theme.of(context).textTheme.caption,
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_name.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _recipientNameController,
          focusNode: _recipientNameFocusNode,
          hintText: "Vladimir Lorentz",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          onSaved: (input) => _localReportModel!.recipientName = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_recipientPositionFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_recipientPositionFocusNode),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_recipient_position.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _recipientPositionController,
          focusNode: _recipientPositionFocusNode,
          hintText: "Gérant",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          onSaved: (input) => _localReportModel!.recipientPosition = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_recipientBirthDayFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_recipientBirthDayFocusNode),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_recipient_birth_date.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _recipientBirthDayController,
                    focusNode: _recipientBirthDayFocusNode,
                    hintText: "##/##/####",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')})
                    ],
                    readOnly: true,
                    onTap: () async {
                      DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime(DateTime.now().year - 40),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );

                      if (dateTime != null) {
                        _recipientBirthDateTime = dateTime;
                        _recipientBirthDayController.text = KeicyDateTime.convertDateTimeToDateString(
                          dateTime: _recipientBirthDateTime,
                          formats: "d/m/Y",
                        );
                      }
                    },
                    validator: (input) => input.isNotEmpty && input.length != 10
                        ? LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
                        : null,
                    onChanged: (input) => (input.length == 10) ? FocusScope.of(context).requestFocus(_recipientBirthCityFocusNode) : null,
                    onSaved: (input) => _localReportModel!.recipientBirthDate = KeicyDateTime.convertDateTimeToDateString(
                      dateTime: _recipientBirthDateTime,
                    ),
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_customerCityFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_customerCityFocusNode),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 10),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.NewReportPageString_recipient_birth_city.tr(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // Text(
                      //   "  *",
                      //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                      // ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 5),
                  CustomTextFormField(
                    controller: _recipientBirthCityController,
                    focusNode: _recipientBirthCityFocusNode,
                    hintText: "Lyon",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    onSaved: (input) => _localReportModel!.recipientBirthCity = input,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_recipientEmailFocusNode),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_recipientEmailFocusNode),
                  ),
                ],
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_recipient_email.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _recipientEmailController,
          focusNode: _recipientEmailFocusNode,
          hintText: "vladimir@legatus.fr",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (input) => input.isNotEmpty && !KeicyValidators.isValidEmail(input) ? LocaleKeys.ValidateErrorString_emailErrorText.tr() : null,
          onSaved: (input) => _localReportModel!.recipientEmail = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_recipientPhoneNumberFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_recipientPhoneNumberFocusNode),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Text(
              LocaleKeys.NewReportPageString_recipient_phone.tr(),
              style: Theme.of(context).textTheme.caption,
            ),
            // Text(
            //   "  *",
            //   style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 5),
        CustomTextFormField(
          controller: _recipientPhoneNumberController,
          focusNode: _recipientPhoneNumberFocusNode,
          hintText: "# ## ## ## ##",
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
          errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(heightDp! * 6),
          ),
          prefixIcon: Container(
            alignment: Alignment.center,
            child: Text("+33 0", style: Theme.of(context).textTheme.subtitle1),
          ),
          prefixIconConstraints: BoxConstraints(maxWidth: widthDp! * 50),
          keyboardType: TextInputType.number,
          inputFormatters: [
            MaskTextInputFormatter(mask: '# ## ## ## ##', filter: {"#": RegExp(r'[0-9]')})
          ],
          validator: (input) => input.isNotEmpty && input.replaceAll(" ", "").length != 9
              ? LocaleKeys.ValidateErrorString_textlengthErrorText.tr(namedArgs: {"length": "9"})
              : null,
          onSaved: (input) => _localReportModel!.recipientPhone = input,
          onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_recipientPhoneNumberFocusNode),
          onEditingComplete: () => FocusScope.of(context).requestFocus(_recipientPhoneNumberFocusNode),
        ),
      ],
    );
  }
}
