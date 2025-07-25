// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legatus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Pages/ReportPage/report_page.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:uuid/uuid.dart';

class NewReportView extends StatefulWidget {
  final bool? isNew;
  final LocalReportModel? localReportModel;

  const NewReportView({Key? key, this.isNew, this.localReportModel}) : super(key: key);

  @override
  NewReportViewState createState() => NewReportViewState();
}

class NewReportViewState extends State<NewReportView> with SingleTickerProviderStateMixin {
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _addressComplementController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _addressComplementFocusNode = FocusNode();
  final FocusNode _zipFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerStreetController = TextEditingController();
  final TextEditingController _customerComplementController = TextEditingController();
  final TextEditingController _customerZipController = TextEditingController();
  final TextEditingController _customerCityController = TextEditingController();
  final TextEditingController _cropFormController = TextEditingController();
  final TextEditingController _cropSirenController = TextEditingController();
  final TextEditingController _cropRCSController = TextEditingController();

  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _customerStreetFocusNode = FocusNode();
  final FocusNode _customerComplementFocusNode = FocusNode();
  final FocusNode _customerZipFocusNode = FocusNode();
  final FocusNode _customerCityFocusNode = FocusNode();
  final FocusNode _cropFromFocusNode = FocusNode();
  final FocusNode _cropSirenFocusNode = FocusNode();
  final FocusNode _cropRCSFocusNode = FocusNode();

  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPositionController = TextEditingController();
  final TextEditingController _recipientBirthDayController = TextEditingController();
  final TextEditingController _recipientBirthCityController = TextEditingController();
  final TextEditingController _recipientEmailController = TextEditingController();
  final TextEditingController _recipientPhoneNumberController = TextEditingController();

  final FocusNode _recipientNameFocusNode = FocusNode();
  final FocusNode _recipientPositionFocusNode = FocusNode();
  final FocusNode _recipientBirthDayFocusNode = FocusNode();
  final FocusNode _recipientBirthCityFocusNode = FocusNode();
  final FocusNode _recipientEmailFocusNode = FocusNode();
  final FocusNode _recipientPhoneNumberFocusNode = FocusNode();

  MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(mask: '# ## ## ## ##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter dateFormatter = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  LocalReportModel? _localReportModel;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // bool _init = false;
  bool? _isNew;

  LocalReportProvider? _localReportProvider;
  KeicyProgressDialog? _keicyProgressDialog;

  DateTime? _reportDateTime;
  DateTime? _recipientBirthDateTime;

  Map<String, dynamic> _updatedStatus = <String, dynamic>{};

  // Position? _currentPosition;
  // ignore: cancel_subscriptions
  StreamSubscription? _locationSubscription;

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
      layout: Layout.column,
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
      _timeController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: 'H:i');
    } else {
      _reportDateTime = KeicyDateTime.convertDateStringToDateTime(dateString: _localReportModel!.date!);
      if (_localReportModel!.recipientBirthDate != "") {
        _recipientBirthDateTime = KeicyDateTime.convertDateStringToDateTime(dateString: _localReportModel!.recipientBirthDate!);
      } else {}

      ///
      _nameController.text = _localReportModel!.name!;
      _dateController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime, formats: "d/m/Y");
      _timeController.text = _localReportModel!.time!.substring(0, 5);
      _descriptionController.text = _localReportModel!.description!;

      ///
      _streetController.text = _localReportModel!.street!;
      _addressComplementController.text = _localReportModel!.complement!;
      _zipController.text = _localReportModel!.zip!;
      _cityController.text = _localReportModel!.city!;
      _latitudeController.text = _localReportModel!.latitude!;
      _longitudeController.text = _localReportModel!.longitude!;

      ///
      _customerNameController.text = _localReportModel!.customerName!;
      _customerStreetController.text = _localReportModel!.customerStreet!;
      _customerComplementController.text = _localReportModel!.customerComplement!;
      _customerZipController.text = _localReportModel!.customerZip!;
      _customerCityController.text = _localReportModel!.customerCity!;
      _cropFormController.text = _localReportModel!.customerCorpForm!;
      _cropSirenController.text = _localReportModel!.customerCorpSiren!;
      _cropRCSController.text = _localReportModel!.customerCorpRcs!;

      ///
      _recipientNameController.text = _localReportModel!.recipientName!;
      _recipientPositionController.text = _localReportModel!.recipientPosition!;
      _recipientBirthDayController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _recipientBirthDateTime, formats: "d/m/Y");
      _recipientBirthCityController.text = _localReportModel!.recipientBirthCity!;
      _recipientEmailController.text = _localReportModel!.recipientEmail!;
      _recipientPhoneNumberController.text = _localReportModel!.recipientPhone!;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _localReportProvider!.addListener(_localReportProviderListener);

      _permissionHander();
    });
  }

  void _permissionHander() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      var position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      setState(() {});
    }

    _locationSubscription = Geolocator.getPositionStream().listen((position) async {
      var position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _localReportProvider!.removeListener(_localReportProviderListener);

    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
      _locationSubscription = null;
    }

    super.dispose();
  }

  void _localReportProviderListener() async {
    if (_localReportProvider!.localReportState.contextName != "NewReportPage") return;

    if (_localReportProvider!.localReportState.progressState != 1 && _keicyProgressDialog!.isShowing()) {
      await _keicyProgressDialog!.hide();
    }

    if (_localReportProvider!.localReportState.progressState == 2) {
      if (_isNew!) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
        _isNew = false;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => ReportPage(localReportModel: _localReportModel),
          ),
          result: _updatedStatus,
        );
        return;
      } else {
        SuccessDialog.show(
          context,
          text: _isNew! ? LocaleKeys.NewReportPageString_createSuccess.tr() : LocaleKeys.NewReportPageString_updateSuccess.tr(),
          callBack: () {
            Navigator.of(context).pop(_updatedStatus);
          },
        );
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
        return;
      }
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
      _localReportModel!.uuid = const Uuid().v4();
      _localReportModel!.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");

      if (Platform.isAndroid) {
        _localReportModel!.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
      } else if (Platform.isIOS) {
        _localReportModel!.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
      }
      // _localReportModel!.reportId = DateTime.now().millisecondsSinceEpoch;

      _localReportProvider!.createLocalReport(
        localReportModel: _localReportModel,
      );
    } else {
      _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportIdStr: "${widget.localReportModel!.date} ${widget.localReportModel!.time}_${_localReportModel!.createdAt}",
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
            widget.localReportModel != null && widget.localReportModel!.name != ""
                ? widget.localReportModel!.name!
                : LocaleKeys.NewReportPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: _mainPanel(),
      ),
    );
  }

  Widget _mainPanel() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
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
                if (widget.localReportModel != null && widget.localReportModel!.reportId != 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 15),
                    child: Column(
                      children: [
                        Text(
                          "Un constat synchronisé ne peut pas être modifié depuis l'application mobile.",
                          style: Theme.of(context).textTheme.bodyText1!,
                        ),
                        SizedBox(height: heightDp! * 20),
                      ],
                    ),
                  ),

                ///
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
                if (widget.localReportModel == null || widget.localReportModel!.reportId == 0)
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                GestureDetector(
                  onTap: () {
                    _localReportModel!.type = type;
                    setState(() {});
                  },
                  child: Text(label, style: Theme.of(context).textTheme.caption),
                )
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
                    inputFormatters: [dateFormatter],
                    readOnly: true,
                    onTap: () async {
                      DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (dateTime != null) {
                        _reportDateTime = dateTime;
                        _dateController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: _reportDateTime, formats: "d/m/Y");
                      }
                    },
                    validator: (input) => input.isEmpty
                        ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(
                            args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
                        : input.length != 10
                            ? LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(
                                args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
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
                    inputFormatters: [LookasTimeCustomFormatter()],
                    // onTap: () async {
                    //   TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                    //   if (timeOfDay != null) {
                    //     _timeController.text = KeicyDateTime.convertDateTimeToDateString(
                    //       dateTime: DateTime(2000, 1, 1, timeOfDay.hour, timeOfDay.minute),
                    //       formats: 'H:i',
                    //     );
                    //   }
                    // },
                    // KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: 'H:i')
                    validator: (input) {
                      if (input.isEmpty) {
                        _timeController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: 'H:i');
                        // return LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: [LocaleKeys.NewReportPageString_time.tr().toLowerCase()]);
                      } else if (input.length != 5) {
                        _timeController.text = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: 'H:i');
                        // return LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(args: [LocaleKeys.NewReportPageString_time.tr().toLowerCase()]);
                      }

                      return;
                    },
                    onSaved: (input) => _localReportModel!.time = "$input:00",
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                    readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                    readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                    readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                    readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                      GestureDetector(
                        onTap: () {
                          _localReportModel!.customerType = type;
                          setState(() {});
                        },
                        child: Text(label, style: Theme.of(context).textTheme.caption),
                      )
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
                readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                          // inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}"))],
                          // keyboardType: TextInputType.number,
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.digitsOnly,
                          // ],
                          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
                    hintText: "17/02/1986",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp! * 6),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [dateFormatter],
                    readOnly: true,
                    onTap: () async {
                      DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime(DateTime.now().year - 40),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                        ? LocaleKeys.ValidateErrorString_inCorrectErrorText.tr(
                            args: [LocaleKeys.NewReportPageString_date.tr().toLowerCase()])
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
                    readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
          readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
          validator: (input) =>
              input.isNotEmpty && !KeicyValidators.isValidEmail(input) ? LocaleKeys.ValidateErrorString_emailErrorText.tr() : null,
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
          hintText: "7 67 04 84 43",
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
          inputFormatters: [phoneFormatter],
          // readOnly: (widget.localReportModel != null && widget.localReportModel!.reportId != 0),
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
