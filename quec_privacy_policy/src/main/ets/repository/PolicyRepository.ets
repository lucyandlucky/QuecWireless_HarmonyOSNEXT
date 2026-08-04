import { i18n } from '@kit.LocalizationKit';
import { PolicyDocument } from '../model/PolicyDocument';
import { PolicyType } from '../model/PolicyRoute';
import { PolicyTermDto } from '../model/PolicyTermDto';
import { PolicyApi, PolicyDataSource } from '../service/PolicyApi';

function getCurrentLanguage(): string {
  return i18n.System.getSystemLanguage()
}

export class PolicyRepository {
  private readonly api: PolicyDataSource
  private readonly languageProvider: () => string

  constructor() {
    this.api = new PolicyApi()
    this.languageProvider = getCurrentLanguage
  }

  private normalizeUrl(value?: string | null): string {
    return value?.trim() ?? ''
  }

  public async getLatest(type: PolicyType): Promise<PolicyDocument> {
    const term: PolicyTermDto = await this.api.getLatest(type)

    const language: string = this.languageProvider().toLowerCase()
    const isChinese: boolean = language.startsWith('zh')

    const htmlUrl: string = this.normalizeUrl(isChinese ? term.htmlCnFileUrl : term.htmlEnFileUrl)
    const pdfUrl: string = this.normalizeUrl(isChinese ? term.pdfCnFileUrl : term.pdfEnFileUrl)

    if (htmlUrl.length === 0) {
      throw new Error('Policy HTML URl is empty')
    }

    return { htmlUrl, pdfUrl }
  }
}